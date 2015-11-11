module PageMagic
  # class ElementContext - resolves which element definition to use when accessing the browser.
  class ElementContext
    attr_reader :page_element

    def initialize(page_element)
      @page_element = page_element
    end

    # acts as proxy to element defintions defined on @page_element
    def method_missing(method, *args, &block)
      return page_element.send(method, *args, &block) if page_element.methods.include?(method)

      element_definition_builder = page_element.element_by_name(method)
      definition_class = element_definition_builder.definition_class
      definition = definition_class.new(element_definition_builder.options)
      definition.init(page_element)
      definition
    end

    def respond_to?(*args)
      page_element.element_definitions.keys.include?(args.first)
    end
  end
end
