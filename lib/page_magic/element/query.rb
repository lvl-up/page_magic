# frozen_string_literal: true

module PageMagic
  class Element
    # class Query - executes query on capybara driver
    class Query

      class Multi < Query
        def find(capybara_element)
          capybara_element.all(*selector_args, **options).to_a.tap do |result|
            raise Capybara::ElementNotFound if result.empty?
          end
        end
      end

      class Single < Query
        def find(capybara_element)
          capybara_element.find(*selector_args, **options)
        end
      end

      QUERY_TYPES = Hash.new(Single).tap do |hash|
        hash[true] = Multi
      end

      # Message template for execptions raised as a result of calling method_missing
      ELEMENT_NOT_FOUND_MSG = 'Unable to find %s'

      attr_reader :selector_args, :options

      def initialize(selector_args, options: {})
        @selector_args = selector_args
        @options = options
      end

      def execute(capybara_element)
        find(capybara_element)
      rescue Capybara::Ambiguous => e
        raise AmbiguousQueryException, e.message
      rescue Capybara::ElementNotFound => e
        raise ElementMissingException, e.message
      end

      def ==(other)
        other.respond_to?(:selector_args) && selector_args == other.selector_args &&
          other.respond_to?(:options) && options == other.options
      end
    end
  end
end
