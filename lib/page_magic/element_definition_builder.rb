module PageMagic
  # Builder for creating ElementDefinitions
  class ElementDefinitionBuilder
    INVALID_SELECTOR_MSG = 'Pass a locator/define one on the class'.freeze
    attr_reader :definition_class, :options, :selector, :type, :element, :query_builder

    def initialize(definition_class:, selector:, type:, options: { multiple_results: false }, element: nil)
      unless element
        selector ||= definition_class.selector
        raise UndefinedSelectorException, INVALID_SELECTOR_MSG if selector.nil? || selector.empty?
      end

      @definition_class = definition_class
      @selector = selector
      @type = type
      @query_builder = Element::QueryBuilder.find(type)

      @options = options
      @element = element
    end

    # @return [Capybara::Query] query to find this element in the browser
    def build_query
      multiple_results = options.delete(:multiple_results) || false
      query_builder.build(selector, options, multiple_results: multiple_results)
    end

    # Create new instance of the ElementDefinition modeled by this builder
    # @param [Object] browser_element capybara browser element corresponding to the element modelled by this builder
    # @return [Element] element definition
    def build(browser_element)
      definition_class.new(browser_element)
    end

    def ==(other)
      return false unless other.is_a?(ElementDefinitionBuilder)
      this = [options, selector, type, element, definition_class]
      this == [other.options, other.selector, other.type, other.element, other.definition_class]
    end
  end
end
