module PageMagic
  class ElementDefinitionBuilder
    attr_reader :definition_class, :options
    def initialize(definition_class, options)
      @definition_class = definition_class
      @options = options
    end

    def build(page_element, browser_element)
      definition_class.new(options).tap do |definition|
        definition.init(page_element, browser_element)
      end
    end

    def ==(other)
      other.is_a?(ElementDefinitionBuilder) && options == other.options
    end
  end
end
