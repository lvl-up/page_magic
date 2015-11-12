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

      builder = page_element.element_by_name(method)
      browser_element = builder.element || find(builder.selector, builder.type, builder.options)

      builder.build(browser_element, page_element)
    end

    # Find an element inside page_element
    # @param [Hash] selector selector to be used. See {Selector} for valid types
    # @param [Symbol] type type of the element being searched for
    # @param [Hash] options additional options be passed to Capybara
    # @return [Object] the Capybara browser element that this element definition is tied to.
    def find(selector, type, options)
      query = Element::Query.find(type).build(selector, options)
      page_element.browser_element.find(*query)
    end

    def respond_to?(*args)
      page_element.element_definitions.keys.include?(args.first)
    end
  end
end
