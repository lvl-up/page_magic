# frozen_string_literal: true

module PageMagic
  class Comparator
    # class Map - used to model parameter matching requirements
    class ParameterMap < Comparator
      def initialize(map)
        comparator = normalise(map).keys.each_with_object({}) do |key, params|
          params[key] = Comparator.for(map[key])
        end

        fuzzy = comparator.values.any?(&:fuzzy?)
        super(comparator, fuzzy)
      end

      def <=>(other)
        return 0 if empty? && other.empty?
        return 1 if other.empty?
        if (comparator.keys.size <=> other.comparator.keys.size).zero?
          return literal_matchers.size <=> other.literal_matchers.size
        end

        0
      end

      def empty?
        comparator.empty?
      end

      def literal_matchers
        comparator.values.find_all { |matcher| !matcher.fuzzy? }
      end

      def match?(params)
        params_copy = normalise(params)
        comparator.each do |key, value|
          param = params_copy[key]
          return false unless value&.match?(param)
        end
        true
      end

      private

      def normalise(hash)
        hash.keys.each_with_object({}) do |key, map|
          map[key.to_sym] = hash[key]
        end
      end
    end
  end
end
