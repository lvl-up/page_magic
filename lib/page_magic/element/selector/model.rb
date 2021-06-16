# frozen_string_literal: true

module PageMagic
  class Element
    class Selector
      # class model - represents the parameters for capybara finder methods
      class Model
        attr_reader :args, :options

        def initialize(args, options = {})
          @args = args
          @options = options
        end

        def ==(other)
          other.args == args && other.options == options
        end
      end
    end
  end
end
