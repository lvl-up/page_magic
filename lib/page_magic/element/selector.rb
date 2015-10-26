module PageMagic
  class Element

    # class Selector - models the selection criteria understood by Capybara
    class Selector
      class << self
        def find(name)
          selector = constants.find { |constant| constant.to_s.downcase == name.to_s.downcase }
          fail UnsupportedCriteriaException unless selector
          const_get(selector)
        end
      end

      def build(element_type, locator)
        [].tap do |array|
          array << element_type if supports_type
          array << name if name
          array << formatter.call(locator)
        end
      end

      attr_reader :name, :formatter, :supports_type

      def initialize(selector = nil, supports_type: false, &formatter)
        @name = selector
        @formatter = formatter || proc { |arg| arg }
        @supports_type = supports_type
      end

      XPATH = Selector.new(:xpath, supports_type: false)
      ID = Selector.new(:id, supports_type: false)
      LABEL = Selector.new(:field, supports_type: false)

      CSS = Selector.new(supports_type: false)
      TEXT = Selector.new(supports_type: true)
      NAME = Selector.new(supports_type: false) do |arg|
        "*[name='#{arg}']"
      end
    end
  end
end
