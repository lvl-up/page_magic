module PageMagic
  class Element
    # class Query - executes query on capybara driver
    class Query
      # Message template for execptions raised as a result of calling method_missing
      ELEMENT_NOT_FOUND_MSG = 'Unable to find %s'.freeze

      attr_reader :args
      def initialize(args)
        @args = args
      end

      def execute(capybara_element)
        result = capybara_element.all(*args)

        if result.empty?
          capybara_query = Capybara::Query.new(*args)
          raise ElementMissingException, ELEMENT_NOT_FOUND_MSG % capybara_query.description
        end

        result
      end

      def ==(other)
        other.respond_to?(:args) && args == other.args
      end
    end
  end
end
