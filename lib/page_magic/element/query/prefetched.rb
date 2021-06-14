module PageMagic
  class Element
    class Query
      class Prefetched < Query
        def initialize(prefetched_element)
          @prefetched_element = prefetched_element
        end

        # Returns the object provided to `initialize`
        # The supplied block will be used to decorate the results
        # @return [Capybara::Node::Element] the object supplied to `initialize`
        def find(_capybara_element, &block)
          block.call(prefetched_element)
        end

        private
        attr_reader :prefetched_element
      end
    end
  end
end
