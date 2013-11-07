module PageMagic
  class Session
    attr_reader :browser
    attr_accessor :current_page

    include WaitUntil

    def initialize browser
      @browser = browser
    end

    def visit page
      @browser.visit page.url
      @current_page = page.new self
      self
    end

    def move_to page_class
      page_class = eval(page_class) if page_class.is_a?(String)
      @current_page = page_class.new self
      wait.until { browser.current_url == page_class.url }
    end

    def method_missing name, *args, &block
      @current_page.send(name, *args, &block)
    end
  end
end