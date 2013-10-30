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

      field_definition, action = nil, nil
      @page_element.elements(@browser, *args).each do |page_element|

        field_minus_action, action = resolve_action(method, page_element)

        case page_element.name
          when field_minus_action
            field_definition = page_element
          when method
            field_definition = page_element
          else
            next
        end
        break if field_definition
      end

      raise ElementMissingException, "Could not find: #{method}" unless field_definition

      result = field_definition.locate

      return ElementContext.new(field_definition, result, @caller, *args) if field_definition.class.is_a? PageSection

      [:set, :select_option, :unselect_option, :click].each do |action_method|
        apply_hooks(page_element: result,
                    capybara_method: action_method,
                    before_hook: field_definition.before_hook,
                    after_hook: field_definition.after_hook,
        )
      end

      action ? result.send(action) : result
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


    def resolve_action(field, field_definition)
      field_as_string = field.to_s
      actions = {/^click_/ => :click}

      actions.each do |prefix, action|
        if field_as_string =~ prefix && field_as_string.gsub(/^click_/, '').to_sym == field_definition.name
          return field_as_string.gsub(/^click_/, '').to_sym, action
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
