module PageMagic
  # Builder for creating ElementDefinitions
  class ElementDefinitionBuilder
    attr_reader :definition_class, :options, :selector, :type, :element
    def initialize(definition_class:, selector:, type:, options:{}, element: nil)
      @definition_class = definition_class
      @selector = selector
      @type = type
      @options = options
      @element = element
    end

    # Create new instance of the ElementDefinition modeled by this builder
    # @param [Element] parent_page_element element containing the element modelled by this builder
    # @param [Object] browser_element capybara browser element corresponding to the element modelled by this builder
    # @return [Element] element definition
    def build(parent_page_element, browser_element)
      definition_class.new(options).tap do |definition|
        definition.init(parent_page_element, browser_element)
      end
    end

    def ==(other)
      return false unless other.is_a?(ElementDefinitionBuilder)
      this = [options, selector, type, element, definition_class]
      this == [other.options, other.selector, other.type, other.element, other.definition_class]
    end
  end
end
