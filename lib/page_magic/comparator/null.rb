# frozen_string_literal: true

module PageMagic
  class Comparator
    # models mapping used to relate pages to uris
    class Null < Comparator
      def initialize(_comparator = nil)
        super(nil, false)
      end

      def match?(_value)
        true
      end

      def <=>(other)
        return 0 if other.is_a?(Null)

        1
      end

      def present?
        false
      end
    end
  end
end
