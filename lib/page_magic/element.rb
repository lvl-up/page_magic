require 'page_magic/method_observer'
require 'page_magic/selector'
module PageMagic

  class UnsupportedCriteriaException < Exception

  end

  class Criteria

    class << self
      def find(name)
        constant = self.constants.find { |constant| constant.to_s.downcase == name.to_s.downcase }
        fail UnsupportedCriteriaException unless constant
        self.const_get(constant)
      end
    end

    def args value
      args = []
      args << name if name
      args << formatter.call(value)
      args
    end

    attr_reader :name, :formatter
    def initialize selector=nil, &formatter
      @name = selector
      @formatter = formatter || proc{|arg| arg}
    end

    XPath = Criteria.new(:xpath)
    ID = Criteria.new(:id)
    LABEL = Criteria.new(:field)

    CSS = Criteria.new
    TEXT = Criteria.new
    Name = Criteria.new do |arg|
      "*[name='#{arg}']"
    end
  end


  class Selectors

    class << self
      def all
        @all ||= {}
      end

      def []= type, selector
        all[type] = selector
      end

      def [] type
        all[type]
      end
    end

    attr_reader :type

    def initialize type=nil, &block
      @type = type
      @formatter = block || proc { |locator| locator.to_a }
      self.class[type] = self
    end

    Element = Selectors.new
    Link = Selectors.new(:link)
    Button = Selectors.new(:button)


    def args(locator, supplied_args)
      selection_criteria = []
      selection_criteria << type() if type()
      selection_criteria << Criteria.find(locator.keys.first).args(locator.values.first)
      selection_criteria << supplied_args unless supplied_args.empty?
      selection_criteria.flatten
    end

    def self.find type
      constant = self.constants.find { |constant| constant.to_s.downcase == type.to_s.downcase }
      return Element unless constant
      self.const_get(constant)
    end

  end
  class Element
    EVENT_TYPES = [:set, :select, :select_option, :unselect_option, :click]
    DEFAULT_HOOK = proc {}.freeze
    attr_reader :type, :name, :parent_page_element, :browser_element

    include Elements, MethodObserver, Selector
    extend Selector

    class << self
      def inherited(clazz)
        clazz.extend(Elements)
      end
    end

    def initialize(name,
                   parent_page_element,
                   type: :element,
                   selector: {},
                   browser_element: nil,
                   &block)
      @browser_element = browser_element
      @selector = selector

      @before_hook = DEFAULT_HOOK
      @after_hook = DEFAULT_HOOK
      @parent_page_element = parent_page_element
      @type = type
      @name = name.to_s.downcase.to_sym
      expand(&block) if block
    end

    alias expand instance_exec

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

      selector_copy = selector.dup
      method = selector_copy.keys.first
      selector = selector_copy.delete(method)
      selector = {method => selector}
      new_selector = Selectors.find(type)

      @browser_element = parent_browser_element.send(:find, *new_selector.args(selector, selector_copy)).tap do |raw_element|
        wrap_events(raw_element)
      end
    end

    def ==(other)
      return false unless other.is_a?(Element)
      this = [type, name, selector, before, after]
      this == [other.type, other.name, other.selector, other.before, other.after]
    end

    private

    def element_context(*args)
      ElementContext.new(self, @browser_element, self, *args)
    end

    def wrap_events(raw_element)
      EVENT_TYPES.each do |action_method|
        if raw_element.respond_to?(action_method)
          apply_hooks(raw_element: raw_element,
                      capybara_method: action_method,
                      before_hook: before,
                      after_hook: after)
        end
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