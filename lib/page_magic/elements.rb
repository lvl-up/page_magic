module PageMagic
  module Elements
    class InvalidElementNameException < Exception
    end

    class InvalidMethodNameException < Exception
    end

    def self.extended clazz
      clazz.class_eval do
        attr_reader :browser_element

        def elements browser_element, *args
          self.class.elements browser_element, *args
        end

        def element_definitions
          self.class.element_definitions
        end
      end
    end

    def method_added method
      raise InvalidMethodNameException, "method name matches element name" if element_definitions[method]
    end


    def elements(browser_element, *args)
      element_definitions.values.collect { |definition| definition.call(browser_element, *args) }
    end

    def elements?
      !element_definitions.empty?
    end

    TYPES = [:element, :text_field, :button, :link, :checkbox, :select_list, :radios, :textarea]
    TYPES.each do |type|
      define_method type do |*args, &block|
        name, selector = args
        add_element_definition(name) do |parent_element|
          Element.new(name, parent_element, type, selector, &block)
        end
      end
    end

    def section *args, &block
      first_arg = args.first
      if first_arg.kind_of?(PageMagic::Section)
        section_class, name, selector = args
        add_element_definition(name) do |parent_browser_element|
          section_class.new(parent_browser_element, name, selector)
        end

      elsif first_arg.is_a?(Symbol)
        name, selector = args

        add_element_definition(name) do |parent_browser_element, *args_for_section|
          page_section = Class.new do
            extend PageMagic::Section
          end

          page_section.parent_browser_element = parent_browser_element.browser_element

          case selector
            when Hash
              page_section.selector selector
            else
              #page_section.browser_element = selector
          end

          block = block || Proc.new{}
          page_section.class_exec *args_for_section, &block
          page_section.new(parent_browser_element, name, selector)
        end
      end



    end

    def add_element_definition name, &block
      raise InvalidElementNameException, "duplicate page element defined" if element_definitions[name]
      raise InvalidElementNameException, "a method already exists with this method name" if instance_methods.find { |method| method == name }

      element_definitions[name] = block
    end

    def element_definitions
      @element_definitions ||= {}
    end
  end
end