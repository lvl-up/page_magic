module PageMagic
  class Matcher
    class Comparator
      class << self
        def for(comparator)
          klass = { Regexp => Fuzzy, Hash => Map, NilClass => Null }.fetch(comparator.class, Literal)
          klass.new(comparator)
        end
      end

      attr_reader :comparator, :fuzzy

      def initialize(comparator, fuzzy)
        @comparator = comparator
        @fuzzy = fuzzy
      end

      def fuzzy?
        fuzzy
      end

      def to_s
        comparator.to_s
      end

      def ==(other)
        comparator == other.comparator
      end
    end
  end
end
