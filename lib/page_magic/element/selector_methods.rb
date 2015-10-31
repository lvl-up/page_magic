module PageMagic
  class Element
    module SelectorMethods
      def selector(selector = nil)
        return @selector unless selector
        @selector = selector
      end
    end
  end
end
