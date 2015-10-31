module PageMagic
  class Element
    # module SelectorMethods - adds method for getting and setting an element selector
    module SelectorMethods
      def selector(selector = nil)
        return @selector unless selector
        @selector = selector
      end
    end
  end
end
