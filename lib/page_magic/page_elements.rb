module PageMagic
  module PageElements
    class InvalidElementNameException < Exception

    end

    class InvalidMethodNameException < Exception

    end


    def self.extended clazz
      clazz.class_eval do
        attr_reader :browser_element

        def elements browser_element
          self.class.elements browser_element
        end

        def element_definitions
          self.class.element_definitions
        end

      end
    end

    def method_added method
      raise InvalidMethodNameException, "method name matches element name" if elements(nil).find { |element| element.name == method }
    end

    ELEMENT_TYPES = [:element, :text_field, :button, :link, :checkbox, :select_list, :radios, :textarea]

    def elements(browser_element, *args)
      element_definitions.collect { |definition| definition.call(browser_element, *args) }
    end

    def elements?
      !element_definitions.empty?
    end

    ELEMENT_TYPES.each do |field|
      define_method field do |*args, &block|
        name, selector = args
        add_element_definition(name) do |browser_element|
          case selector
            when Hash, NilClass
              PageElement.new(name, browser_element, field, selector, &block)
            else
              PageElement.new(name, selector, field, nil, &block)
          end

        end
      end
    end

    def section *args, &block
      case args.first
        when Symbol
          name, selector = args
          add_element_definition(name) do |browser_element, *args|
            page_section = Class.new do
              extend PageMagic::PageSection
            end
            page_section.class_exec browser_element, *args, &block
            page_section.new(browser_element, name, selector)
          end
        else
          section_class, name, selector = args
          add_element_definition(name) do |browser_element|
            section_class.new(browser_element, name, selector)
          end
      end


    end

    def add_element_definition name, &block
      elements = elements(nil)
      raise InvalidElementNameException, "duplicate page element defined" if elements.find { |element| element.name == name }
      raise InvalidElementNameException, "a method already exists with this method name" if instance_methods.find { |method| method == name }

      element_definitions << block
    end

    def element_definitions
      @element_definitions ||= []
    end
  end
end
