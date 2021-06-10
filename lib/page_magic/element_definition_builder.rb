# frozen_string_literal: true

module PageMagic
  # Builder for creating ElementDefinitions
  class ElementDefinitionBuilder
    INVALID_SELECTOR_MSG = 'Pass a locator/define one on the class'
    attr_reader :definition_class, :selector, :type, :element, :query

    def initialize(definition_class:, selector:, type:, query_class: PageMagic::Element::Query::Single, options: {}, element: nil)

      @definition_class = definition_class

      if element
        @query = PageMagic::Element::Query::Prefetched.new(element)
      else
        selector ||= definition_class.selector
        raise UndefinedSelectorException, INVALID_SELECTOR_MSG if selector.nil? || selector.empty?

        # TODO - maybe create two classes of element definition builder one for prefetched and selector based
        selector = PageMagic::Element::Selector.find(selector.keys.first).build(type, selector.values.first, options: options)
        @query = query_class.new(*selector.args, options: selector.options)
      end
    end

    # Create new instance of the ElementDefinition modeled by this builder
    # @param [Object] browser_element capybara browser element corresponding to the element modelled by this builder
    # @return [Element] element definition TODO - change
    def build(browser_element)
      query.execute(browser_element) do |result|
        definition_class.new(result)
      end
    end

    def ==(other)
      return false unless other.is_a?(ElementDefinitionBuilder)

      this = [query, definition_class]
      this == [other.query, other.definition_class]
    end
  end
end
