module PageMagic
  # class ElementContext - resolves which element definition to use when accessing the browser.
  class ElementContext
    attr_reader :page_element

    def initialize(page_element)
      @page_element = page_element
    end

    def method_missing(method, *args, &block)
      return page_element.send(method, *args, &block) if page_element.methods.include?(method)

      element_locator_factory = page_element.element_definitions[method]

      fail ElementMissingException, "Could not find: #{method}" unless element_locator_factory

      element_locator = element_locator_factory.call(page_element, *args)

      element_locator.section? ? element_locator : element_locator.browser_element
    end

    def respond_to?(*args)
      page_element.element_definitions.keys.include?(args.first)
    end
  end
end
