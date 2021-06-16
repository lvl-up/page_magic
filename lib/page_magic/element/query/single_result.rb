# frozen_string_literal: true

module PageMagic
  class Element
    class Query
      # class SingleResult - use to query when only one result should be expected
      class SingleResult < Query
        # Find an element
        # The supplied block will be used to decorate the results
        # @param [Capybara::Node::Element] capybara_element the element to be searched within
        # @return [Object] the results
        def find(capybara_element, &block)
          block.call capybara_element.find(*selector_args, **options)
        rescue Capybara::Ambiguous => e
          raise AmbiguousQueryException, e.message
        end
      end
    end
  end
end
