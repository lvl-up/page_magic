# frozen_string_literal: true

module PageMagic
  class Element
    # class Query - executes query on capybara driver
    class Query
      # Message template for execptions raised as a result of calling method_missing
      ELEMENT_NOT_FOUND_MSG = 'Unable to find %s'

      attr_reader :args, :multiple_results

      alias multiple_results? multiple_results

      def initialize(args, multiple_results: false)
        @args = args
        @multiple_results = multiple_results
      end

      def execute(capybara_element)
        if multiple_results
          get_results(capybara_element)
        elsif args.last.is_a?(Hash)
          # TODO: - make sure there is a test around this.
          capybara_element.find(*args[0...-1], **args.last)
        else
          capybara_element.find(*args)
        end
      rescue Capybara::Ambiguous => e
        raise AmbiguousQueryException, e.message
      rescue Capybara::ElementNotFound => e
        raise ElementMissingException, e.message
      end

      def ==(other)
        other.respond_to?(:args) && args == other.args
      end

      private

      def get_results(capybara_element)
        capybara_element.all(*args).to_a.tap do |result|
          raise Capybara::ElementNotFound if result.empty?
        end
      end
    end
  end
end
