# frozen_string_literal: true
require_relative 'query/multi'
require_relative 'query/single'
module PageMagic
  class Element
    # class Query - executes query on capybara driver
    class Query
      attr_reader :selector_args, :options

      def initialize(*selector_args, options: {})
        @selector_args = selector_args
        @options = options
      end

      def execute(capybara_element, &block)
        find(capybara_element, &(block||proc{|arg|arg}))
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
