require 'page_magic/element/method_observer'
require 'page_magic/element/selector_methods'
require 'page_magic/element/selector'
require 'page_magic/element/query'
module PageMagic
  class Element
    EVENT_TYPES = [:set, :select, :select_option, :unselect_option, :click]
    DEFAULT_HOOK = proc {}.freeze
    attr_reader :type, :name, :parent_page_element, :browser_element

    include Elements, MethodObserver, SelectorMethods
    extend SelectorMethods

    class << self
      def inherited(clazz)
        clazz.extend(Elements)
      end
    end

    def initialize(name, parent_page_element, type: :element, selector: {}, browser_element: nil, &block)
      @browser_element = browser_element
      @selector = selector

      @before_hook = DEFAULT_HOOK
      @after_hook = DEFAULT_HOOK
      @parent_page_element = parent_page_element
      @type = type
      @name = name.to_s.downcase.to_sym
      expand(&block) if block
    end

    def expand(*args, &block)
      instance_exec(*args, &block)
      self
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
        return browser_element.send(method, *args, &block) if browser_element.respond_to?(method)
        return parent_page_element.send(method, *args, &block)
      rescue NoMethodError, ElementMissingException
        super
      end
    end

    def respond_to?(*args)
      super || element_context.respond_to?(*args) || browser_element.respond_to?(*args)
    end

    def browser_element(*_args)
      return @browser_element if @browser_element

      fail UndefinedSelectorException, 'Pass a locator/define one on the class' if selector.empty?

      query = Query.find(type).build(query_selector, query_options)

      @browser_element = parent_browser_element.find(*query).tap do |raw_element|
        wrap_events(raw_element)
      end
    end

    def ==(other)
      return false unless other.is_a?(Element)
      this = [type, name, selector, before, after]
      this == [other.type, other.name, other.selector, other.before, other.after]
    end

    private

    def query_selector
      Hash[*selector.first]
    end

    def query_options
      selector.dup.delete_if { |key, _value| key == selector.keys.first }
    end

    def element_context(*args)
      ElementContext.new(self, @browser_element, self, *args)
    end

    def wrap_events(raw_element)
      EVENT_TYPES.each do |action_method|
        next unless raw_element.respond_to?(action_method)
        apply_hooks(raw_element: raw_element,
                    capybara_method: action_method,
                    before_hook: before,
                    after_hook: after)
      end
    end

    def parent_browser_element
      parent_page_element.browser_element
    end

    def apply_hooks(raw_element:, capybara_method:, before_hook:, after_hook:)
      original_method = raw_element.method(capybara_method)
      this = self

      raw_element.define_singleton_method(capybara_method) do |*arguments, &block|
        this.instance_exec(&before_hook)
        original_method.call(*arguments, &block)
        this.instance_exec(&after_hook)
      end
    end
  end
end
