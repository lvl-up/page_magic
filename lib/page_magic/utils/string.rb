module PageMagic
  module Utils
    # module String - contains methods for manipulating strings
    module String
      class << self
        def classify(string_or_symbol)
          string_or_symbol.to_s.split('_').collect(&:capitalize).reduce(:+)
        end
      end
    end
  end
end
