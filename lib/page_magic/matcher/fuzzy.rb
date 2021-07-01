module PageMagic
  class Matcher
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
