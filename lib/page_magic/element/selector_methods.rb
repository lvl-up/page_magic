# frozen_string_literal: true

module PageMagic
  class Element
    # module SelectorMethods - adds method for getting and setting an element selector
    module SelectorMethods
      # Gets/Sets a selector
      # @param [Hash] selector method for locating the browser element. E.g. text: 'the text'
      def selector(selector = nil)
        return @selector unless selector

        @selector = selector
      end
    end
  end
end
