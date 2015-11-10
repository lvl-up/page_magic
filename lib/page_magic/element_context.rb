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

      page_element.element_by_name(method)
    end

    def respond_to?(*args)
      page_element.element_definitions.keys.include?(args.first)
    end
  end
end
