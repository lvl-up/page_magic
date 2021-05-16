# frozen_string_literal: true

module PageMagic
  class Element
    # class Selector - models the selection criteria understood by Capybara
    class Selector
      class << self
        # Find a Selecor using it's name
        # @param [Symbol] name the name of the required Selector in snakecase format. See class constants for available
        #  selectors
        # @return [Selector] returns the predefined selector with the given name
        def find(name)
          selector = constants.find { |constant| constant.to_s.casecmp(name.to_s).zero? }
          raise UnsupportedCriteriaException unless selector

          const_get(selector)
        end
      end

      attr_reader :name, :formatter, :exact, :supports_type

      def initialize(selector = nil, supports_type: false, exact: false, &formatter)
        @name = selector
        @formatter = formatter || proc { |arg| arg }
        @supports_type = supports_type
        @exact = exact
      end

      # Build selector query parameters for Capybara's find method
      # @param [Symbol] element_type the type of browser element being found. e.g :link
      # @param [Hash] locator the selection method and its parameter. E.g. text: 'click me'
      def build(element_type, locator)
        [].tap do |array|
          array << element_type if supports_type
          array << name if name
          array << formatter.call(locator)
          array << { exact: true } if exact
        end
      end

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
