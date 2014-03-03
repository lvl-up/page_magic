require 'watir-webdriver'
module PageMagic

  class UnsupportedSelectorException < Exception

  end
  class UndefinedSelectorException < Exception
  end

  class MissingLocatorOrSelector < Exception
  end

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

  class Element
    attr_reader :type, :name, :selector, :before_hook, :after_hook, :browser_element, :locator

    include Location, AjaxSupport
    extend Location, Elements
    class << self
      def selector selector=nil
        return @selector unless selector

        if @parent_browser_element
          @browser_element = locate_in @parent_browser_element, selector
        end

        @selector = selector
      end

      def default_before_hook
        @default_before_hook ||= Proc.new {}
      end

      def default_after_hook
        @default_after_hook ||= Proc.new {}
      end

      attr_accessor :parent_browser_element, :browser_element
    end

    def initialize name, parent_page_element, type=nil, selector=nil, &block
      @parent_page_element = parent_page_element

      if selector.nil? || selector.is_a?(Hash)
        @selector = selector || self.class.selector
        @browser_element = self.class.browser_element
      else
        @browser_element = selector
      end

      @type, @name = type, name.downcase.to_sym
      @before_hook, @after_hook = self.class.default_before_hook, self.class.default_after_hook

      raise UndefinedSelectorException, "Pass a selector/define one on the class" unless @selector || @browser_element

      instance_eval &block if block_given?
    end

    def section?
      @type == :section
    end

    def session
      @parent_page_element.session
    end

    def before &block
      @before_hook = block
    end

    def after &block
      @after_hook = block
    end

    def method_missing method, *args
      begin
        ElementContext.new(self, @browser_element, self, *args).send(method, args.first)
      rescue ElementMissingException
        begin
          @browser_element.send(method, *args)
        rescue
          super
        end
      end
    end

    def locate *args
      return @browser_element if section?
      if @selector && @selector.is_a?(Hash)
        locate_in(@browser_element, @selector)
      else
        @browser_element
      end
    end


    def == page_element
      page_element.is_a?(Element) &&
          @type == page_element.type &&
          @name == page_element.name &&
          @selector == page_element.selector
      @before_hook == page_element.before_hook &&
          @after_hook == page_element.after_hook
    end
  end
end