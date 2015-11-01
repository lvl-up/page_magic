module PageMagic
  module ClassMethods
    include Elements

    def inherited(clazz)
      clazz.element_definitions.merge!(element_definitions)
    end
  end
end
