module PageMagic
  class Element
    class Query
      class Multi < Query
        # Find multiple elements
        # The supplied block will be used to decorate the results
        # @param [Capybara::Node::Element] capybara_element the element to be searched within
        # @return [Array<Capybara::Node::Element>] the results
        def find(capybara_element, &block)
          capybara_element.all(*selector_args, **options).to_a.tap do |result|
            raise Capybara::ElementNotFound if result.empty?
          end.collect{|result| block.call(result)}
        end
      end
    end
  end
end

