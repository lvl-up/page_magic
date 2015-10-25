module PageMagic
  class Element
    class Query
      class << self
        def find(type)
          query = constants.find { |constant| constant.to_s.downcase == type.to_s.downcase }
          return ELEMENT unless query
          const_get(query)
        end
      end

      attr_reader :type

      def initialize(type = nil)
        @type = type
      end

      def build(locator, options)
        [].tap do |array|
          array << type if type
          array << Selector.find(locator.keys.first).build(locator.values.first)
          array << options unless options.empty?
        end.flatten
      end

      ELEMENT = Query.new
      LINK = Query.new(:link)
      BUTTON = Query.new(:button)
    end
  end
end
