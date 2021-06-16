# frozen_string_literal: true

module PageMagic
  module Elements
    # hooks for objects that inherit classes that include the Elements module
    module InheritanceHooks
      # Copies parent element definitions on to subclass
      # @param [Class] clazz - inheriting class
      def inherited(clazz)
        super
        clazz.element_definitions.merge!(element_definitions)
      end
    end
  end
end
