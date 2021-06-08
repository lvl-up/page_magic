# frozen_string_literal: true

module PageMagic
  # Builder for creating ElementDefinitions
  class ElementDefinitionBuilder
    INVALID_SELECTOR_MSG = 'Pass a locator/define one on the class'
    attr_reader :definition_class, :selector, :type, :element, :query

    def initialize(definition_class:, selector:, type:, query_class: PageMagic::Element::Query::Single, options: {}, element: nil)

      unless element
        selector ||= definition_class.selector
        raise UndefinedSelectorException, INVALID_SELECTOR_MSG if selector.nil? || selector.empty?
      end

      @definition_class = definition_class
      @selector = selector
      @type = type

      if element
        @element = element
      else
        # TODO - maybe create two classes of element definition builder one for prefetched and seletor based
        selector = PageMagic::Element::Selector.find(selector.keys.first).build(type, selector.values.first, options: options)
        @query = query_class.new(*selector.args, options: selector.options)
      end
    end

    # Create new instance of the ElementDefinition modeled by this builder
    # @param [Object] browser_element capybara browser element corresponding to the element modelled by this builder
    # @return [Element] element definition
    def build(browser_element)
      definition_class.new(browser_element)
    end

    def ==(other)
      return false unless other.is_a?(ElementDefinitionBuilder)

      this = [selector, type, element, definition_class, query]
      this == [other.selector, other.type, other.element, other.definition_class, other.query]
    end
  end
end
