module PageMagic

  class ElementMissingException < Exception

  end

  class ElementContext

    attr_reader :caller, :page_element

    def initialize page_element, browser, caller, *args
      @page_element = page_element
      @browser = browser
      @caller = caller
    end

    def method_missing method, *args
      return @caller.send(method, *args) if @executing_hooks
      return @page_element.send(method, *args) if @page_element.methods.include?(method)

      element_locator_factory =  @page_element.element_definitions[method]

      raise ElementMissingException, "Could not find: #{method}" unless element_locator_factory

      if args.empty?
        element_locator = element_locator_factory.call(@page_element, nil)
      else
        element_locator = element_locator_factory.call(@page_element, *args)
      end

      [:set, :select_option, :unselect_option, :click].each do |action_method|
        apply_hooks(page_element: element_locator.browser_element,
                    capybara_method: action_method,
                    before_hook: element_locator.before,
                    after_hook: element_locator.after,
        )
      end

      element_locator.section? ? element_locator : element_locator.browser_element
    end

    def respond_to? *args
      @page_element.element_definitions.keys.include?(args.first)
    end

    def apply_hooks(options)
      _self = self
      page_element, capybara_method = options[:page_element], options[:capybara_method]
      if page_element.respond_to?(capybara_method)
        original_method = page_element.method(capybara_method)

        page_element.define_singleton_method capybara_method do |*arguments, &block|
          _self.call_hook &options[:before_hook]
          original_method.call *arguments, &block
          _self.call_hook &options[:after_hook]
        end
      end
    end


    def call_hook &block
      @executing_hooks = true
      result = self.instance_exec @browser, &block
      @executing_hooks = false
      result
    end

  end
end
