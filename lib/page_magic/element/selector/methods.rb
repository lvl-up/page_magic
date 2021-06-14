module PageMagic
  class Element
    class Selector
      # module SelectorMethods - adds method for getting and setting an element selector
      module Methods
        # Gets/Sets a selector
        # @param [Hash<Symbol,String>] selector method for locating the browser element. E.g. text: 'the text'
        def selector(selector = nil)
          return @selector unless selector

          @selector = selector
        end
      end
    end
  end
end
