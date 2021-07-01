# frozen_string_literal: true

module PageMagic
  class Comparator
    # class Fuzzy - used for modeling and comparing components that are 'fuzzy' i.e. respond to `=~` e.g. a Regexp
    class Fuzzy < Comparator
      def initialize(comparator)
        super(comparator, true)
      end

      def match?(value)
        comparator =~ value ? true : false
      end

      def <=>(other)
        return -1 if other.is_a?(Null)
        return 1 unless other.fuzzy?

        0
      end
    end
  end
end
