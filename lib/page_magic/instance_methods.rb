module PageMagic
  # module InstanceMethods - provides instance level methods for page objects
  module InstanceMethods
    attr_reader :browser, :session, :browser_element

    include Watchers, SessionMethods, WaitMethods, Element::Locators

    # Creates a new instance
    # @param [Session] session session that provides gateway to the browser throw the users chosen browser
    def initialize(session = Session.new(Capybara.current_session))
      @browser = session.raw_session
      @session = session

      @browser_element = browser
    end

    # @return [Array] class level defined element definitions
    def element_definitions
      self.class.element_definitions
    end

    # executes block stored using {ClassMethods#on_load} against self
    # @return [Element] self
    def execute_on_load
      instance_eval(&self.class.on_load)
      self
    end

    # proxy to the defined page element definitions
    # @return [Object] the result of accessing the requested page element through its definition
    def method_missing(method, *args)
      element_context.send(method, *args)
    end

    def respond_to?(*args)
      contains_element?(args.first) || super
    end

    # @return the current page title
    def title
      browser.title
    end

    # @return the page text
    def text
      browser.text
    end

    # check for the presense of specific text on the page
    # @param [String] string the string to check for
    # @return [Boolean]
    def text_on_page?(string)
      text.downcase.include?(string.downcase)
    end

    private

    def contains_element?(method)
      element_definitions.keys.include?(method)
    end

    def element_context
      ElementContext.new(self)
    end
  end
end
