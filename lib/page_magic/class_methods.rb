module PageMagic
  module ClassMethods
    def url(url = nil)
      @url = url if url
      @url
    end

    def inherited(clazz)
      clazz.element_definitions.merge!(element_definitions)
    end
  end
end
