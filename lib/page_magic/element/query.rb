# frozen_string_literal: true
require_relative 'query/multi'
require_relative 'query/single'
require_relative 'query/prefetched'
module PageMagic
  class Element
    # class Query - executes query on capybara driver
    class Query
      attr_reader :selector_args, :options
      DEFAULT_DECORATOR = proc{|arg|arg}.freeze

      def initialize(*selector_args, options: {})
        @selector_args = selector_args
        @options = options
      end

      # TODO - test for decoration?
      # Run query against the scope of the given element
      # The supplied block will be used to decorate the results
      # @param [Capybara::Node::Element] capybara_element the element to be searched within
      # @return [Array<Capybara::Node::Element>] the results
      def execute(capybara_element, &block)
        find(capybara_element, &(block||DEFAULT_DECORATOR))
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
