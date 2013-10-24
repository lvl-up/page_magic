require 'watir-webdriver'
module PageMagic

  class UnsupportedSelectorException < Exception

  end

  class PageElement

    class MissingLocatorOrSelector < Exception
    end

    include PageElements
    include AjaxSupport

    module ::Watir
      SelectList = Select
    end

    attr_reader :type, :name, :selector, :before_hook, :after_hook, :browser_element, :locator

    class << self
      def default_before_hook
        @default_before_hook ||= Proc.new {}
      end

      def default_after_hook
        @default_after_hook ||= Proc.new {}
      end
    end

    def initialize name, browser_element, type=nil, selector=nil, &block
      @browser_element = browser_element
      @type = type
      @name = name.downcase.to_sym
      @selector = selector
      @before_hook, @after_hook = self.class.default_before_hook, self.class.default_after_hook
      instance_eval &block if block_given?
    end

    def before &block
      @before_hook = block
    end

    def after &block
      @after_hook = block
    end

    def locate *args
      if @selector && @selector.is_a?(Hash)
        method, selector = @selector.to_a.flatten
        case method
          when :id
            @browser_element.find("##{selector}")
          when :name
            @browser_element.find("*[name='#{selector}']")
          when :label
            @browser_element.find_field(selector)
          when :text
            if @type == :link
              @browser_element.find_link(selector)
            elsif @type == :button
              @browser_element.find_button(selector)
            else
              raise UnsupportedSelectorException
            end
          when :css
            @browser_element.find(:css, selector)
          else
            raise UnsupportedSelectorException

        end
      else
        @browser_element
      end

      #@browser_element.find_field(element_type, @selector)
    end

    alias_method :inherited_locate_method, :locate

    def == page_element
      page_element.is_a?(PageElement) &&
          @type == page_element.type &&
          @name == page_element.name &&
          @selector == page_element.selector
      @before_hook == page_element.before_hook &&
          @after_hook == page_element.after_hook
    end
  end
end