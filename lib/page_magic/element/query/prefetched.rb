module PageMagic
  class Element
    class Query
      class Prefetched < Query
        def initialize(prefetched_element)
          @prefetched_element = prefetched_element
        end

        def find(_capybara_element, &block)
          block.call(prefetched_element)
        end

        private
        attr_reader :prefetched_element
      end
    end
  end
end
