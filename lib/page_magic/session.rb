module PageMagic
  class Session
    attr_reader :browser, :current_page

    def initialize browser
      @browser = browser
    end

    def visit page
      @browser.visit page.url
      @current_page = page.new @browser
      self
    end

    def method_missing name, *args, &block
      @current_page.send(name, *args, &block)
    end
  end
end