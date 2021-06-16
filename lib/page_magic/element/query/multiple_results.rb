# frozen_string_literal: true

module PageMagic
  class Element
    class Query
      # class MultipleResults - use to query for multiple results
      class MultipleResults < Query
        # Find multiple elements
        # The supplied block will be used to decorate the results
        # @param [Capybara::Node::Element] capybara_element the element to be searched within
        # @return [Array<Capybara::Node::Element>] the results
        def find(capybara_element, &block)
          results = capybara_element.all(*selector_args, **options).to_a.tap do |result|
            raise Capybara::ElementNotFound if result.empty?
          end
          results.collect { |result| block.call(result) }
        end
      end
    end
  end
end
