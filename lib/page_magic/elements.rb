require 'active_support/inflector'
module PageMagic
  module Elements
    class InvalidElementNameException < Exception
    end

    class InvalidMethodNameException < Exception
    end

    def self.extended(clazz)
      clazz.class_eval do
        unless instance_methods.include?(:browser_element)
          attr_reader :browser_element
        end

        def element_definitions
          self.class.element_definitions
        end
      end
    end

    def method_added(method)
      fail InvalidMethodNameException, 'method name matches element name' if element_definitions[method]
    end

    def elements(browser_element, *args)
      element_definitions.values.collect { |definition| definition.call(browser_element, *args) }
    end

    def element *args, &block
      type = __callee__
      section_class = remove_argument(args, Class) || Element

      selector = remove_argument(args, Hash)
      selector ||= section_class.selector if section_class.respond_to?(:selector)

      name = remove_argument(args, Symbol)
      name ||= section_class.name.demodulize.underscore.to_sym unless section_class.is_a?(Element)

      options =  selector ? {selector: selector} : {browser_element: args.delete_at(0)}

      add_element_definition(name) do |parent_browser_element, *e_args|
        section_class.new(name, parent_browser_element, options.merge(type: type)).tap do |section|
          section.expand(*e_args, &(block || proc {}))
        end
      end
    end

    TYPES = [:text_field, :button, :link, :checkbox, :select_list, :radios, :textarea, :section]

    TYPES.each{|type|alias_method type, :element}

    def add_element_definition(name, &block)
      fail InvalidElementNameException, 'duplicate page element defined' if element_definitions[name]

      methods = respond_to?(:instance_methods) ? instance_methods : methods()
      fail InvalidElementNameException, 'a method already exists with this method name' if methods.find { |method| method == name }

      element_definitions[name] = block
    end

    def element_definitions
      @element_definitions ||= {}
    end

    private

    def remove_argument(args, clazz)
      argument = args.find { |arg| arg.is_a?(clazz) }
      args.delete(argument)
    end
  end
end
