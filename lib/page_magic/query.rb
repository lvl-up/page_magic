module PageMagic
  class Query
    class << self
      def find(type)
        constant = constants.find { |constant| constant.to_s.downcase == type.to_s.downcase }
        return ELEMENT unless constant
        const_get(constant)
      end
    end

    attr_reader :type

    def initialize(type = nil, &_block)
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
