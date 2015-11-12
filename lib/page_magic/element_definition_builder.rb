module PageMagic
  # Builder for creating ElementDefinitions
  class ElementDefinitionBuilder
    INVALID_SELECTOR_MSG = 'Pass a locator/define one on the class'
    attr_reader :definition_class, :options, :selector, :type, :element

    def initialize(definition_class:, selector:, type:, options:{}, element: nil)
      unless element
        selector ||= definition_class.selector
        fail UndefinedSelectorException, INVALID_SELECTOR_MSG if selector.nil? || selector.empty?
      end

      @definition_class = definition_class
      @selector = selector
      @type = type
      @options = options
      @element = element
    end

    # @return [Capybara::Query] query to find this element in the browser
    def build_query
      Element::Query.find(type).build(selector, options)
    end

    # Create new instance of the ElementDefinition modeled by this builder
    # @param [Element] parent_page_element element containing the element modelled by this builder
    # @param [Object] browser_element capybara browser element corresponding to the element modelled by this builder
    # @return [Element] element definition
    def build(browser_element, parent_page_element)
      definition_class.new(browser_element, parent_page_element)
    end

    def ==(other)
      return false unless other.is_a?(ElementDefinitionBuilder)
      this = [options, selector, type, element, definition_class]
      this == [other.options, other.selector, other.type, other.element, other.definition_class]
    end
  end
end
