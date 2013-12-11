require 'wait'
module PageMagic
  class Session
    attr_reader :browser
    attr_accessor :current_page

    def initialize browser
      @browser = browser
    end

    def visit page
      @browser.visit page.url
      @current_page = page.new self
      self
    end

    def current_url
      @browser.current_url
    end

    def move_to page_class
      page_class = eval(page_class) if page_class.is_a?(String)
      @current_page = page_class.new self
      wait_until { browser.current_url == page_class.url }
    end

    def wait_until &block
      @wait ||= Wait.new
      @wait.until &block
    end

    def set_cookie name, value, options = {}
      @browser.driver.set_cookie(name,value)
    end

    def remove_cookie name
      @browser.driver.remove_cookie name
    end

    def method_missing name, *args, &block
      @current_page.send(name, *args, &block)
    end
  end
end