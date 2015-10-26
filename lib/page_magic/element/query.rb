module PageMagic
  class Element
    # class Query - models overall queries for Capybara, queries can include:
    #  - requirements on element type
    #  - selection criteria, modeled through the Selector class
    #  - options

    class Query
      class << self
        def find(type)
          query = constants.find { |constant| constant.to_s.downcase == type.to_s.downcase }
          return ELEMENT unless query
          const_get(query)
        end
      end

      attr_reader :type

      # @param type -
      def initialize(type = nil)
        @type = type
      end

      def build(locator, options = {})
        [].tap do |array|
          selector = Selector.find(locator.keys.first)
          array << selector.build(type, locator.values.first)
          array << options unless options.empty?
        end.flatten
      end

      ELEMENT = Query.new
      TEXT_FIELD = CHECKBOX = SELECT_LIST = RADIOS = TEXTAREA = Query.new(:field)
      LINK = Query.new(:link)
      BUTTON = Query.new(:button)
    end
  end
end
