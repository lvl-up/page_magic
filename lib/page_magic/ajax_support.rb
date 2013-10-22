module PageMagic
  module AjaxSupport
    def on_element_with_trigger css_selector, event, browser, &block
      set_variable_on_event(browser, css_selector, event)
      yield
      wait_until(:timeout_after => 20.seconds, :retry_every => 1.second) do
        event_triggered(browser, event)
      end
    end

    def event_triggered(browser, variable)
      browser.execute_script("return #{variable}_triggered")
    end

    def set_variable_on_event(browser, element, event)
      variable_name="#{event}_triggered"
      browser.execute_script("#{variable_name}=false")
      browser.execute_script("$('#{element}').on('#{event}', function(){#{variable_name}=true})")
    end
  end
end