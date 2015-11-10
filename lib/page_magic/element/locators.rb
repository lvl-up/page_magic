module PageMagic
  class Element
    # contains method for finding element definitions
    module Locators
      ELEMENT_MISSING_MSG = 'Could not find: %s'

      # find an element definition based on its name
      # @param [Symbol] name name of the element
      # @return [Element] element definition with the given name
      def element_by_name(name)
        defintion = element_definitions[name]
        fail ElementMissingException, (ELEMENT_MISSING_MSG % name) unless defintion
        defintion.call(self)
      end
    end
  end
end
