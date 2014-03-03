module PageMagic

  class Element
    attr_reader :type, :name, :selector, :browser_element

    include Location, AjaxSupport, Elements

    def initialize name, parent_page_element, type=nil, selector=nil, &block
      if selector.is_a?(Hash)
        @selector = selector
      else
        @browser_element = selector
      end

      @parent_page_element, @type, @name = parent_page_element, type, name.downcase.to_sym
      instance_eval &block if block_given?
    end

    def selector selector=nil
      return @selector unless selector
      @selector = selector
    end

    def section?
      @type == :section
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
      raise UndefinedSelectorException, "Pass a selector/define one on the class" unless @selector
      @browser_element = locate_in(@parent_page_element.browser_element, @selector) if @selector
    end
  end
end