# frozen_string_literal: true
require_relative 'selector/model'
module PageMagic
  class Element # Capybara::Finder
    # class Selector - models the selection criteria understood by Capybara
    class Selector
      class << self
        # Find a Selector using it's name
        # @param [Symbol] name the name of the required Selector in snakecase format. See class constants for available
        #  selectors
        # @return [Selector] returns the predefined selector with the given name
        def find(name)
          selector_name = selector_constant_name(name)
          raise UnsupportedCriteriaException unless selector_name

          const_get(selector_name)
        end

        private
        def selector_constant_name(name)
          constants.find { |constant| constant.to_s.casecmp(name.to_s).zero? }
        end
      end

      # Initialize a new selector
      # a block can be supplied to decorate the query. E.g.
      # @example
      #  Selector.new(supports_type: false) do |arg|
      #    "*[name='#{arg}']"
      #  end
      #
      # @param [Symbol] selector the identifier for the selector
      # @param [Boolean] supports_type whether the element type being searched for can be used as part of the query
      # @param [Boolean] exact whether an exact match is required. E.g. element should include exactly the same text
      def initialize(selector = nil, supports_type: false, exact: false, &formatter)
        @selector = selector
        @formatter = formatter || proc { |arg| arg }
        @supports_type = supports_type
        @options = {}.tap do |hash|
          hash[:exact] = true if exact
        end
      end

      # Build selector query parameters for Capybara's find method
      # @param [Symbol] element_type the type of browser element being found. e.g :link
      # @param [Hash<Symbol,String>] locator the selection method and its parameter. E.g. text: 'click me'
      def build(element_type, locator, options:{})
        array = [type(element_type), selector, formatter.call(locator)].compact
        Model.new(array, self.options.merge(options))
      end

      private
      def type(element_type)
        supports_type ? element_type : nil
      end

      attr_reader :supports_type, :options, :selector, :formatter

      XPATH = Selector.new(:xpath, supports_type: false)
      ID = Selector.new(:id, supports_type: false)
      LABEL = Selector.new(:field, supports_type: false, exact: true)

      CSS = Selector.new(supports_type: false)
      TEXT = Selector.new(supports_type: true)
      NAME = Selector.new(supports_type: false) do |arg|
        "*[name='#{arg}']"
      end
    end
  end
end
