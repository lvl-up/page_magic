# frozen_string_literal: true

require 'active_support/inflector'
require 'page_magic/element_definition_builder'
require 'page_magic/elements/inheritance_hooks'
require 'page_magic/elements/config'
require 'page_magic/elements/types'

module PageMagic
  # module Elements - contains methods that add element definitions to the objects it is mixed in to
  module Elements
    INVALID_METHOD_NAME_MSG = 'a method already exists with this method name'

    class << self
      def extended(clazz)
        clazz.extend(InheritanceHooks)
      end

      private
      def define_element_methods(types)
        types.each { |type| alias_method type, :element }
      end

      def define_pluralised_element_methods(types)
        types.each { |type| alias_method type.to_s.pluralize, :elements }
      end
    end

    # Creates an element defintion. TODO - re-write
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
    #  @param [capybara_options]
    def element(*args, **capybara_options, &block)
      define_element(*args,
                     type: __callee__,
                     query_class: PageMagic::Element::Query::Single,
                     **capybara_options,
                     &block)
    end

    def elements(*args, **capybara_options, &block)
      define_element(*args,
                     type: __callee__.to_s.singularize.to_sym,
                     query_class: PageMagic::Element::Query::Multi,
                     **capybara_options,
                     &block)
    end

    define_element_methods(TYPES)
    define_pluralised_element_methods(TYPES)

    # @return [Hash] element definition names mapped to blocks that can be used to create unique instances of
    #  and {Element} definitions
    def element_definitions
      @element_definitions ||= {}
    end

    private

    def define_element(*args, type:, query_class:, **capybara_options, &block)
      block ||= proc {}
      args << capybara_options unless capybara_options.empty?
      config = Config.build(args, type).validate!

      validate_element_name(config.name)

      element_definitions[config.name] = proc do |parent_element, *e_args|
        config.definition_class = Class.new(config.element_class) do
          parent_element(parent_element)
          class_exec(*e_args, &block)
        end

        ElementDefinitionBuilder.new(query_class: query_class, **config.element_options)
      end
    end

    def validate_element_name(name)
      raise InvalidElementNameException, 'duplicate page element defined' if element_definitions[name]

      methods = respond_to?(:instance_methods) ? instance_methods : methods()
      raise InvalidElementNameException, INVALID_METHOD_NAME_MSG if methods.find { |method| method == name }
    end

    def method_added(method)
      super
      raise InvalidMethodNameException, 'method name matches element name' if element_definitions[method]
    end
  end
end
