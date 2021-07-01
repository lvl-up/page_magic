# frozen_string_literal: true

require_relative 'comparator/fuzzy'
require_relative 'comparator/literal'
require_relative 'comparator/parameter_map'
require_relative 'comparator/null'

module PageMagic
  # class Comparator - used for comparing components used for mapping pages
  class Comparator
    class << self
      def for(comparator)
        klass = { Regexp => Fuzzy, Hash => ParameterMap, NilClass => Null }.fetch(comparator.class, Literal)
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
