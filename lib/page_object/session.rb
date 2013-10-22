module PageObject
  class Session
    attr_reader :browser
    def initialize browser
      @browser = browser
    end

    def visit page
      @browser.visit page.url
      @current_page = page.new @browser
    end
  end
end