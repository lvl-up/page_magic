module PageMagic

  module MethodObserver
    def singleton_method_added arg
      @singleton_methods_added = true unless arg == :singleton_method_added
    end

    def singleton_methods_added?
      @singleton_methods_added == true
    end
  end

  class Element
    attr_reader :type, :name, :selector, :browser_element

    include Elements

    class << self
      def inherited clazz
        clazz.extend(Elements)

        def clazz.selector selector=nil
          return @selector unless selector
          @selector = selector
        end
      end
    end

    def initialize name, parent_page_element, options, &block
      options = {type: :element, selector: {}, browser_element: nil}.merge(options)
      @browser_element = options[:browser_element]
      @selector = options[:selector]

      @before_hook = proc {}
      @after_hook = proc {}
      @parent_page_element, @type, @name = parent_page_element, options[:type], name.to_s.downcase.to_sym

      extend MethodObserver
      expand &block if block
    end

    def expand *args, &block
      instance_exec *args, &block
    end

    def selector selector=nil
      return @selector unless selector
      @selector = selector
    end

    def section?
      !element_definitions.empty? || singleton_methods_added?
    end

    def session
      @parent_page_element.session
    end

    def before &block
      return @before_hook unless block
      @before_hook = block
    end

    def after &block
      return @after_hook unless block
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

    def browser_element *args
      return @browser_element if @browser_element
      raise UndefinedSelectorException, "Pass a selector/define one on the class" if @selector.empty?
      if @selector
        method, selector = @selector.to_a.flatten
        browser_element = @parent_page_element.browser_element
        @browser_element = case method
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
      @browser_element
    end
  end
end
