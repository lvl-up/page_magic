module PageMagic
  class Matcher
    class Literal < Comparator
      def initialize(comparator)
        super(comparator, false)
      end

      def match?(value)
        comparator == value
      end

      def <=>(other)
        return 1 if other.fuzzy? || other.is_a?(Null)

        0
      end
    end
  end
end
