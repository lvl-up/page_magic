require 'wait'
module PageMagic
  class Session
    attr_accessor :current_page, :raw_session, :transitions

    def initialize browser
      @raw_session = browser
    end

    def define_transitions transitions
      @transitions = transitions
    end

    def current_page
      if transitions
        mapping = transitions.keys.find do |key|
          current_url.include?(key)
        end
        @current_page = transitions[mapping].new(self) if transitions[mapping]
      end
      @current_page
    end

    def visit page
      raw_session.visit page.url
      @current_page = page.new self
      self
    end

    def current_path
      raw_session.current_path
    end

    def current_url
      raw_session.current_url
    end

    def wait_until &block
      @wait ||= Wait.new
      @wait.until &block
    end

    def method_missing name, *args, &block
      current_page.send(name, *args, &block)
    end

  end
end