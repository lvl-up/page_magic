module PageMagic
  # module ClassMethods - contains class level methods for PageObjects
  module ClassMethods
    # Default block to be run when a page is loaded. This is used if a specific handler is not registered
    DEFAULT_ON_LOAD = proc {}

    # getter setter for storing the page url
    # @param [String] url the url of the page
    def url(url = nil)
      @url = url if url
      @url
    end

    # sets block to run when page has loaded
    # if one has not been set on the page object class it will return a default block that does nothing
    def on_load(&block)
      return @on_load || DEFAULT_ON_LOAD unless block
      @on_load = block
    end

    # Visit this page based on the class level registered url
    # @param [Object] application rack application (optional)
    # @param [Symbol] browser name of browser
    # @param [Hash] options browser driver specific options
    # @return [Session] active session configured to be using an instance of the page object modeled by this class
    def visit(application: nil, browser: :rack_test, options: {})
      session_options = { browser: browser, options: options, url: url }
      session_options[:application] = application if application

      PageMagic.session(session_options).tap do |session|
        session.visit(self, url: url)
      end
    end
  end
end
