module PageObject

  class ElementMissingException < Exception

  end

  class ElementContext
    include PageElements

    attr_reader :caller, :page_element
    enabled = proc { |browser_element| browser_element.enabled? }
    visible = proc { |browser_element| browser_element.visible? }
    set = proc { |browser_element| browser_element.set? }
    has_value = proc { |browser_element| !browser_element.value.nil? }

    ElementTypes = {
        button: {
            presence_check: enabled
        },
        link: {
            presence_check: visible
        },
        checkbox: {
            presence_check: set
        },
        select_list: {
            presence_check: has_value
        },
        text_field: {
            presence_check: has_value
        },
        textarea: {
            presence_check: has_value
        },
        radios: {
            presence_check: proc { |browser_element|
              !browser_element.find { |radio| radio.parent.text == value }.nil?
            }
        },
    }

    def initialize page_element, browser, caller, *args
      @page_element = page_element
      unless page_element.is_a? ElementContext
        self.element_definitions.concat(@page_element.element_definitions)
      end
      @browser = browser
      @caller = caller
    end

    def method_missing method, *args
      return @caller.send(method, *args) if @executing_hooks
      return @page_element.send(method, *args) if @page_element.methods.include?(method)


      field, input = method, args.first

      field_definition, check, action = nil, nil, nil
      elements(@browser).each do |page_element|

        field_minus_action, action = resolve_action(field, page_element)
        field_minus_check, check = resolve_check(field)

        case page_element.name
          when field_minus_check
            field_definition = page_element
          when field_minus_action
            field_definition = page_element
          when field
            field_definition = page_element
          else
            next
        end
      end

      raise ElementMissingException, "Could not find: #{field}" unless field_definition

      result = field_definition.locate(input)
      return ElementContext.new(result, @browser, @caller, *args) if result.class.is_a? InlinePageSection
      return ElementContext.new(field_definition, result, @caller, *args) if field_definition.class.is_a? PageSection

      _self = self
      [:set, :select_option, :unselect_option, :click].each do |action_method|
        original_method = result.method(action_method)

        result.define_singleton_method action_method do |*arguments, &block|
          _self.call_hook &field_definition.before_hook
          original_method.call *arguments, &block
          _self.call_hook &field_definition.after_hook
        end
      end

      action ? result.send(action) : result

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

    def resolve_check(field)
      field_as_string = field.to_s

      checks = {
          '_has_class?' => :has_class,
          '?' => :presence,
          '@' => :reference,
          '_as_text' => :as_text
      }

      checks.each do |suffix, check_type|
        return field_as_string.gsub(suffix, "").to_sym, check_type if field_as_string.end_with?(suffix)
      end
    end

    def call_hook &block
      @executing_hooks = true
      result = self.instance_exec @browser, &block
      @executing_hooks = false
      create_new_context(result) if result.is_a?(Array)
    end

    def create_new_context(result)
      new_context = ElementContext.new(self, @browser, @caller)
      result.each do |new_field|
        new_context.element_definitions << proc { new_field }
      end
      new_context
    end

  end
end
