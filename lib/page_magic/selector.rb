module PageMagic
  module Selector
    def selector(selector = nil)
      return @selector unless selector
      @selector = selector
    end
  end
end