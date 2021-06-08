module PageMagic
  class Element
    class Query
      class Single < Query
        def find(capybara_element)
          capybara_element.find(*selector_args, **options)
        rescue Capybara::Ambiguous => e
          raise AmbiguousQueryException, e.message
        end
      end
    end
  end
end
