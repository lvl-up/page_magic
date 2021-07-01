# frozen_string_literal: true

module PageMagic
  class Comparator
    # class Literal - used for modeling and comparing thing directly. E.g. strings
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
