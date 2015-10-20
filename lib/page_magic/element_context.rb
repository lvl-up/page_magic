module PageMagic
  class ElementMissingException < Exception
  end

  class ElementContext
    EVENT_TYPES = [:set, :select, :select_option, :unselect_option, :click]

    attr_reader :caller, :page_element

    def initialize(page_element, caller, *_args)
      @page_element = page_element
      @caller = caller
    end

    def method_missing(method, *args, &block)
      return page_element.send(method, *args, &block) if page_element.methods.include?(method)

      element_locator_factory = page_element.element_definitions[method]

      fail ElementMissingException, "Could not find: #{method}" unless element_locator_factory

      if args.empty?
        element_locator = element_locator_factory.call(page_element, nil)
      else
        element_locator = element_locator_factory.call(page_element, *args)
      end

      element_locator.section? ? element_locator : element_locator.browser_element
    end

    def respond_to?(*args)
      page_element.element_definitions.keys.include?(args.first)
    end
  end
end
