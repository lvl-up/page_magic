# frozen_string_literal: true

module PageMagic
  # for the benefit of pull review :@
  class Element
    # contains method for finding element definitions
    module Locators
      # message used when raising {ElementMissingException} from methods within this module
      ELEMENT_NOT_DEFINED_MSG = 'Element not defined: %s'

      # find an element definition based on its name
      # @param [Symbol] name name of the element
      # @return [Element] element definition with the given name
      # @raise [ElementMissingException] raised when element with the given name is not found
      def element_by_name(name, *args)
        defintion = element_definitions[name]
        raise ElementMissingException, (ELEMENT_NOT_DEFINED_MSG % name) unless defintion

        defintion.call(self, *args)
      end

      # @return [Array] class level defined element definitions
      def element_definitions
        self.class.element_definitions
      end
    end
  end
end
