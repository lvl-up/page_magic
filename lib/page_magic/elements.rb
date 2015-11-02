require 'active_support/inflector'
module PageMagic
  # module Elements - contains methods that add element definitions to the objects it is mixed in to
  module Elements
    INVALID_METHOD_NAME_MSG = 'a method already exists with this method name'

    class << self
      def included(clazz)
        def clazz.inherited(clazz)
          clazz.element_definitions.merge!(element_definitions)
        end
      end
      alias_method :extended, :included
    end

    def method_added(method)
      fail InvalidMethodNameException, 'method name matches element name' if element_definitions[method]
    end

    def elements(browser_element, *args)
      element_definitions.values.collect { |definition| definition.call(browser_element, *args) }
    end

    def element(*args, &block)
      block ||= proc {}

      section_class = remove_argument(args, Class) || Element
      selector = compute_selector(args, section_class)
      name = compute_name(args, section_class)

      options = { type: __callee__ }
      selector ? options[:selector] = selector : options[:browser_element] = args.delete_at(0)

      add_element_definition(name) do |parent_browser_element, *e_args|
        section_class.new(name, parent_browser_element, options).expand(*e_args, &block)
      end
    end

    TYPES = [:text_field, :button, :link, :checkbox, :select_list, :radios, :textarea]

    TYPES.each { |type| alias_method type, :element }

    def add_element_definition(name, &block)
      fail InvalidElementNameException, 'duplicate page element defined' if element_definitions[name]

      methods = respond_to?(:instance_methods) ? instance_methods : methods()
      fail InvalidElementNameException, INVALID_METHOD_NAME_MSG if methods.find { |method| method == name }

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

    def compute_name(args, section_class)
      name = remove_argument(args, Symbol)
      name || section_class.name.demodulize.underscore.to_sym unless section_class.is_a?(Element)
    end

    def compute_selector(args, section_class)
      selector = remove_argument(args, Hash)
      selector || section_class.selector if section_class.respond_to?(:selector)
    end
  end
end
