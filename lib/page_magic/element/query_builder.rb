require 'capybara/query'
require 'page_magic/element/query'
module PageMagic
  class Element
    # class QueryBuilder - builds query to be executed on capybara driver, queries can include:
    #  - requirements on element type
    #  - selection criteria, modeled through the Selector class
    #  - options
    class QueryBuilder
      class << self
        # Find a query using it's name
        # @param [Symbol] type the name of the required query in snakecase format
        # @return [QueryBuilder] returns the predefined query with the given name
        def find(type)
          query = constants.find { |constant| constant.to_s.casecmp(type.to_s).zero? }
          return ELEMENT unless query
          const_get(query)
        end
      end

      attr_reader :type

      # @param type -
      def initialize(type = nil)
        @type = type
      end

      # Build query parameters for Capybara's find method
      # @param [Hash] locator the location method e.g. text: 'button text'
      # @param [Hash] capybara_options additional options to be provided to Capybara. e.g. count: 3
      # @return [Array] list of compatible capybara query parameters.
      def build(locator, capybara_options = {}, multiple_results: false)
        args = [].tap do |array|
          selector = Selector.find(locator.keys.first)
          array << selector.build(type, locator.values.first)
          array << capybara_options unless capybara_options.empty?
        end.flatten

        Query.new(args, multiple_results: multiple_results)
      end

      ELEMENT = QueryBuilder.new
      TEXT_FIELD = CHECKBOX = SELECT_LIST = RADIO = TEXTAREA = QueryBuilder.new(:field)
      LINK = QueryBuilder.new(:link)
      BUTTON = QueryBuilder.new(:button)
    end
  end
end
