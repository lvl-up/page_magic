# frozen_string_literal: true

module PageMagic
  module Utils
    # module String - contains methods for manipulating strings
    module String
      class << self
        # convert a snake case `String` or `Symbol`
        # @example
        #  classify(:snake_case) # => "SnakeCase"
        # @return [String]
        def classify(string_or_symbol)
          string_or_symbol.to_s.split('_').collect(&:capitalize).reduce(:+)
        end
      end
    end
  end
end
