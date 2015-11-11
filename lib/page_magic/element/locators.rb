module PageMagic
  class Element
    # contains method for finding element definitions
    module Locators
      # message used when raising {ElementMissingException} from methods within this module
      ELEMENT_MISSING_MSG = 'Could not find: %s'

      # find an element definition based on its name
      # @param [Symbol] name name of the element
      # @return [Element] element definition with the given name
      # @raise [ElementMissingException] raised when element with the given name is not found
      def element_by_name(name)
        defintion = element_definitions[name]
        fail ElementMissingException, (ELEMENT_MISSING_MSG % name) unless defintion
        defintion.call
      end

      # @return [Array] class level defined element definitions
      def element_definitions
        self.class.element_definitions
      end
    end
  end
end
