require 'wait'
module PageMagic
  class Session
    attr_accessor :current_page, :raw_session

    def initialize browser
      @raw_session = browser
    end

    def define_transitions transitions
      @transitions = transitions
    end

    def visit page
      @raw_session.visit page.url
      @current_page = page.new self
      self
    end

    def current_path
      @raw_session.current_path
    end

    def current_url
      @raw_session.current_url
    end

    def move_to page_class
      page_class = eval(page_class) if page_class.is_a?(String)
      @current_page = page_class.new self
      wait_until { raw_session.current_url == page_class.url }
    end

    def wait_until &block
      @wait ||= Wait.new
      @wait.until &block
    end

    def method_missing name, *args, &block
      @current_page.send(name, *args, &block)
    end

  end
end