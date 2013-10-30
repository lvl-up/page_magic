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

      field_definition = @page_element.element_definitions[method.to_s.gsub('click_', '').to_sym]
      raise ElementMissingException, "Could not find: #{method}" unless field_definition

      field_definition = field_definition.call(@browser, *args)
      result = field_definition.locate

      return ElementContext.new(field_definition, result, @caller, *args) if field_definition.class.is_a? PageSection

      [:set, :select_option, :unselect_option, :click].each do |action_method|
        apply_hooks(page_element: result,
                    capybara_method: action_method,
                    before_hook: field_definition.before_hook,
                    after_hook: field_definition.after_hook,
        )
      end

      click_action?(method, field_definition) ? result.click : result
    end

    def apply_hooks(options)
      _self = self
      page_element, capybara_method = options[:page_element], options[:capybara_method]

      original_method = page_element.method(capybara_method)

      page_element.define_singleton_method capybara_method do |*arguments, &block|
        _self.call_hook &options[:before_hook]
        original_method.call *arguments, &block
        _self.call_hook &options[:after_hook]
      end
    end


    def click_action?(field, field_definition)
      field_as_string = field.to_s
      (field_as_string =~ /^click_/ && field_as_string.gsub(/^click_/, '').to_sym == field_definition.name)
    end

    def call_hook &block
      @executing_hooks = true
      result = self.instance_exec @browser, &block
      @executing_hooks = false
      result
    end

  end
end
