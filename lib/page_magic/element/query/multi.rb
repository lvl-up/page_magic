module PageMagic
  class Element
    class Query
      class Multi < Query
        def find(capybara_element, &block)
          capybara_element.all(*selector_args, **options).to_a.tap do |result|
            raise Capybara::ElementNotFound if result.empty?
          end.collect{|result| block.call(result)}
        end
      end
    end
  end
end

