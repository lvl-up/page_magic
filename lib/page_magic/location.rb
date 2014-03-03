module PageMagic
  module Location
    def locate_in browser_element, selector
      method, selector = selector.to_a.flatten
      case method
        when :id
          browser_element.find("##{selector}")
        when :xpath
          browser_element.find(:xpath, selector)
        when :name
          browser_element.find("*[name='#{selector}']")
        when :label
          browser_element.find_field(selector)
        when :text
          if @type == :link
            browser_element.find_link(selector)
          elsif @type == :button
            browser_element.find_button(selector)
          else
            raise UnsupportedSelectorException
          end
        when :css
          browser_element.find(:css, selector)
        else
          raise UnsupportedSelectorException
      end
    end


  end

end