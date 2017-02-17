require 'active_support/inflector'
require 'page_magic/element_definition_builder'
module PageMagic
  # module Elements - contains methods that add element definitions to the objects it is mixed in to
  module Elements
    # hooks for objects that inherit classes that include the Elements module
    module InheritanceHooks
      # Copies parent element definitions on to subclass
      # @param [Class] clazz - inheritting class
      def inherited(clazz)
        clazz.element_definitions.merge!(element_definitions)
      end
    end

    INVALID_METHOD_NAME_MSG = 'a method already exists with this method name'.freeze

    TYPES = [:text_field, :button, :link, :checkbox, :select_list, :radio, :textarea].collect do |type|
      [type, :"#{type}s"]
    end.flatten.freeze

    class << self
      def extended(clazz)
        clazz.extend(InheritanceHooks)
      end
    end

    # Creates an element defintion.
    # Element defintions contain specifications for locating them and other sub elements.
    # if a block is specified then it will be executed against the element defintion.
    # This method is aliased to each of the names specified in {TYPES TYPES}
    # @example
    #   element :widget, id: 'widget' do
    #     link :next, text: 'next'
    #   end
    # @overload element(name, selector, &block)
    #  @param [Symbol] name the name of the element.
    #  @param [Hash] selector a key value pair defining the method for locating this element
    #  @option selector [String] :text text contained within the element
    #  @option selector [String] :css css selector
    #  @option selector [String] :id the id of the element
    #  @option selector [String] :name the value of the name attribute belonging to the element
    #  @option selector [String] :label value of the label tied to the require field
    # @overload element(element_class, &block)
    #  @param [ElementClass] element_class a custom class of element that inherits {Element}.
    #   the name of the element is derived from the class name. the Class name coverted to snakecase.
    #   The selector must be defined on the class itself.
    # @overload element(name, element_class, &block)
    #  @param [Symbol] name the name of the element.
    #  @param [ElementClass] element_class a custom class of element that inherits {Element}.
    #   The selector must be defined on the class itself.
    # @overload element(name, element_class, selector, &block)
    #  @param [Symbol] name the name of the element.
    #  @param [ElementClass] element_class a custom class of element that inherits {Element}.
    #  @param [Hash] selector a key value pair defining the method for locating this element. See above for details
    def element(*args, &block)
      block ||= proc {}
      options = compute_options(args.dup, __callee__)

      section_class = options.delete(:section_class)

      add_element_definition(options.delete(:name)) do |parent_element, *e_args|
        definition_class = Class.new(section_class) do
          parent_element(parent_element)
          class_exec(*e_args, &block)
        end
        ElementDefinitionBuilder.new(options.merge(definition_class: definition_class))
      end
    end

    TYPES.each { |type| alias_method type, :element }

    # @return [Hash] element definition names mapped to blocks that can be used to create unique instances of
    #  and {Element} definitions
    def element_definitions
      @element_definitions ||= {}
    end

    private

    def compute_options(args, type)
      section_class = remove_argument(args, Class) || Element

      { name: compute_name(args, section_class),
        type: type,
        selector: compute_selector(args, section_class),
        options: compute_argument(args, Hash),
        element: args.delete_at(0),
        section_class: section_class }.tap do |hash|
        hash[:options][:multiple_results] = type.to_s.end_with?('s')
      end
    end

    def add_element_definition(name, &block)
      raise InvalidElementNameException, 'duplicate page element defined' if element_definitions[name]

      methods = respond_to?(:instance_methods) ? instance_methods : methods()
      raise InvalidElementNameException, INVALID_METHOD_NAME_MSG if methods.find { |method| method == name }

      element_definitions[name] = block
    end

    def compute_name(args, section_class)
      name = remove_argument(args, Symbol)
      name || section_class.name.demodulize.underscore.to_sym unless section_class.is_a?(Element)
    end

    def compute_selector(args, section_class)
      selector = remove_argument(args, Hash)
      selector || section_class.selector if section_class.respond_to?(:selector)
    end

    def method_added(method)
      raise InvalidMethodNameException, 'method name matches element name' if element_definitions[method]
    end

    def compute_argument(args, clazz)
      remove_argument(args, clazz) || clazz.new
    end

    def remove_argument(args, clazz)
      argument = args.find { |arg| arg.is_a?(clazz) }
      args.delete(argument)
    end
  end
end
