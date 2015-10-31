require 'wait'
module PageMagic
  class InvalidURLException < Exception
  end

  class Session
    URL_MISSING_MSG = 'a path must be mapped or a url supplied'
    REGEXP_MAPPING_MSG = 'URL could not be derived because mapping is a Regexp'

    attr_reader :raw_session, :transitions

    def initialize(browser, url = nil)
      @raw_session = browser
      raw_session.visit(url) if url
      @transitions = {}
    end

    def define_page_mappings(transitions)
      @transitions = transitions
    end

    def current_page
      mapping = find_mapped_page(current_path)
      @current_page = mapping.new(self) if mapping
      @current_page
    end

    def visit(page = nil, url: nil)
      if url
        raw_session.visit(url)
      elsif (path = transitions.key(page))
        fail InvalidURLException, REGEXP_MAPPING_MSG if path.is_a?(Regexp)
        raw_session.visit(url(current_url, path))
      else
        fail InvalidURLException, URL_MISSING_MSG
      end
      @current_page = page.new(self) if page
      self
    end

    def url(base_url, path)
      path = path.sub(%r{^/}, '')
      base_url = base_url.sub(%r{/$}, '')
      "#{base_url}/#{path}"
    end

    def current_path
      raw_session.current_path
    end

    def current_url
      raw_session.current_url
    end

    def wait_until(&block)
      @wait ||= Wait.new
      @wait.until(&block)
    end

    def method_missing(name, *args, &block)
      current_page.send(name, *args, &block)
    end

    def respond_to?(*args)
      super || current_page.respond_to?(*args)
    end

    def find_mapped_page(path)
      mapping = transitions.keys.find do |key|
        string_matches?(path, key)
      end
      transitions[mapping]
    end

    private

    def string_matches?(string, matcher)
      if matcher.is_a?(Regexp)
        string =~ matcher
      elsif matcher.is_a?(String)
        string == matcher
      else
        false
      end
    end
  end
end
