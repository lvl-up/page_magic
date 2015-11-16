module PageMagic
  class Matcher
    attr_reader :key
    def initialize(key)
      @key = key
    end

    def fuzzy?
      key.is_a?(Regexp)
    end

    def path
      key
    end

    def matches? string
      if fuzzy?
        string =~ key
      else
        string == key
      end
    end
  end
end
