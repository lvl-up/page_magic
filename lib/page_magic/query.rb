module PageMagic
  class Query
    class << self
      def find(type)
        constant = constants.find { |constant| constant.to_s.downcase == type.to_s.downcase }
        return Element unless constant
        const_get(constant)
      end
    end

    attr_reader :type

    def initialize(type = nil, &_block)
      @type = type
    end

    def build(locator, options)
      selection_criteria = []
      selection_criteria << type if type
      selection_criteria << Selector.find(locator.keys.first).build(locator.values.first)
      selection_criteria << options unless options.empty?
      selection_criteria.flatten
    end

    Element = Query.new
    Link = Query.new(:link)
    Button = Query.new(:button)
  end
end
