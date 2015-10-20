module PageMagic
  module MethodObserver
    def singleton_method_added(arg)
      @singleton_methods_added = true unless arg == :singleton_method_added
    end

    def singleton_methods_added?
      @singleton_methods_added == true
    end
  end

  class Element
    EVENT_TYPES = [:set, :select, :select_option, :unselect_option, :click]
    attr_reader :type, :name, :selector, :parent_page_element, :browser_element

    include Elements

    class << self
      def inherited(clazz)
        clazz.extend(Elements)

        def clazz.selector(selector = nil)
          return @selector unless selector
          @selector = selector
        end
      end
    end

    DEFAULT_HOOK = proc {}.freeze

    def initialize(name, parent_page_element, options, &block)
      options = { type: :element, selector: {}, browser_element: nil }.merge(options)
      @browser_element = options[:browser_element]
      @selector = options[:selector]

      @before_hook = DEFAULT_HOOK
      @after_hook = DEFAULT_HOOK
      @parent_page_element = parent_page_element
      @type = options[:type]
      @name = name.to_s.downcase.to_sym

      extend MethodObserver
      expand &block if block
    end

    def expand(*args, &block)
      instance_exec *args, &block
    end

    def selector(selector = nil)
      return @selector unless selector
      @selector = selector
    end

    def section?
      !element_definitions.empty? || singleton_methods_added?
    end

    def session
      @parent_page_element.session
    end

    def before(&block)
      return @before_hook unless block
      @before_hook = block
    end

    def after(&block)
      return @after_hook unless block
      @after_hook = block
    end

    def method_missing(method, *args, &block)
      ElementContext.new(self, browser_element, self, *args).send(method, args.first, &block)
    rescue ElementMissingException
      begin
        if browser_element.respond_to?(method)
          browser_element.send(method, *args, &block)
        else
          parent_page_element.send(method, *args, &block)
        end
      rescue Exception
        super
      end
    end

    def respond_to?(*args)
      super || element_context.respond_to?(*args) || browser_element.respond_to?(*args)
    end

    def browser_element(*_args)
      return @browser_element if @browser_element

      fail UndefinedSelectorException, 'Pass a selector/define one on the class' if selector.empty?

      selector_copy = selector.dup
      method = selector_copy.keys.first
      selector = selector_copy.delete(method)
      options = selector_copy

      finder_method, selector_type, selector_arg = case method
                                                   when :id
                                                     [:find, "##{selector}"]
                                                   when :xpath
                                                     [:find, :xpath, selector]
                                                   when :name
                                                     [:find, "*[name='#{selector}']"]
                                                   when :css
                                                     [:find, :css, selector]
                                                   when :label
                                                     [:find_field, selector]
                                                   when :text
                                                     if @type == :link
                                                       [:find_link, selector]
                                                     elsif @type == :button
                                                       [:find_button, selector]
                                                     else
                                                       fail UnsupportedSelectorException
                                                     end

                                                   else
                                                     fail UnsupportedSelectorException
                                                   end

      finder_args = [selector_type, selector_arg].compact
      finder_args << options unless options.empty?

      @browser_element = parent_browser_element.send(finder_method, *finder_args).tap do |browser_element|
        EVENT_TYPES.each do |action_method|
          apply_hooks(page_element: browser_element,
                      capybara_method: action_method,
                      before_hook: before,
                      after_hook: after)
        end
      end
    end

    def parent_browser_element
      parent_page_element.browser_element
    end

    def apply_hooks(page_element:, capybara_method:, before_hook:, after_hook:)
      if page_element.respond_to?(capybara_method)
        original_method = page_element.method(capybara_method)
        _self = self

        page_element.define_singleton_method(capybara_method) do |*arguments, &block|
          _self.call_hook &before_hook
          original_method.call *arguments, &block
          _self.call_hook &after_hook
        end
      end
    end

    def call_hook(&block)
      @executing_hooks = true
      result = instance_exec &block
      @executing_hooks = false
      result
    end

    def ==(page_element)
      page_element.is_a?(Element) &&
        type == page_element.type &&
        name == page_element.name &&
        selector == page_element.selector &&
        before == page_element.before &&
        after == page_element.after
    end

    private

    def element_context(*args)
      ElementContext.new(self, @browser_element, self, *args)
    end
  end
end
