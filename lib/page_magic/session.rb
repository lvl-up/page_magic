require 'wait'
module PageMagic
  class Session
    attr_accessor :current_page, :raw_session, :transitions

    def initialize browser
      @raw_session = browser
    end

    def define_page_mappings transitions
      @transitions = transitions
    end

    def current_page
      if transitions
        mapping = find_mapped_page(current_path)
        @current_page = mapping.new(self) if mapping
      end
      @current_page
    end

    def find_mapped_page path
      mapping = transitions.keys.find do |key|
        string_matches?(path, key)
      end
      transitions[mapping]
    end

    def string_matches?(string, matcher)
      if matcher.is_a?(Regexp)
        string =~ matcher
      elsif matcher.is_a?(String)
        string == matcher
      else
        false
      end
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