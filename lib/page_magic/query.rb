module PageMagic
  class Query
    class << self
      def all
        @all ||= {}
      end

      def []=(type, selector)
        all[type] = selector
      end

      def [](type)
        all[type]
      end
    end

    attr_reader :type

    def initialize(type = nil, &block)
      @type = type
      @formatter = block || proc { |locator| locator.to_a }
      self.class[type] = self
    end

    Element = Query.new
    Link = Query.new(:link)
    Button = Query.new(:button)

    def args(locator, options)
      selection_criteria = []
      selection_criteria << type if type
      selection_criteria << Selector.find(locator.keys.first).args(locator.values.first)
      selection_criteria << options unless options.empty?
      selection_criteria.flatten
    end

    def self.find(type)
      constant = constants.find { |constant| constant.to_s.downcase == type.to_s.downcase }
      return Element unless constant
      const_get(constant)
    end
  end
end
