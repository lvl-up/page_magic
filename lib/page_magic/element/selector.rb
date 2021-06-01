# frozen_string_literal: true

module PageMagic
  class Element # Capybara::Finder
    class SelectorInstance
      attr_reader :args, :options
      def initialize(args, options={})
        @args = args
        @options = options
      end

      def == other
        other.args == self.args && other.options == self.options
      end
    end
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
      # @param [Hash] locator the selection method and its parameter. E.g. text: 'click me'
      def build(element_type, locator, options:{})
        array = [type(element_type), selector, formatter.call(locator)].compact
        SelectorInstance.new(array, self.options.merge(options))
      end



      private
      def type(element_type)
        # supports_type ? Element::Type.new(element_type) : ElementType::Type::Nil
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
