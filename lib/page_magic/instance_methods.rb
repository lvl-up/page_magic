module PageMagic
  # module InstanceMethods - provides instance level methods for page objects
  module InstanceMethods
    attr_reader :browser, :session, :browser_element

    # Creates a new instance
    # @param [Session] session session that provides gateway to the browser throw the users chosen browser
    def initialize(session = Session.new(Capybara.current_session))
      @browser = session.raw_session
      @session = session

      @browser_element = browser
    end

    def title
      browser.title
    end

    def text_on_page?(string)
      text.downcase.include?(string.downcase)
    end

    def visit
      browser.visit self.class.url
      self
    end

    def text
      browser.text
    end

    def method_missing(method, *args)
      element_context.send(method, *args)
    end

    def respond_to?(*args)
      super || element_context.respond_to?(*args)
    end

    def element_definitions
      self.class.element_definitions
    end

    def element_context
      ElementContext.new(self)
    end
  end
end
