module PageMagic
  class UnsupportedCriteriaException < Exception
  end

  class Selector
    class << self
      def find(name)
        constant = constants.find { |constant| constant.to_s.downcase == name.to_s.downcase }
        fail UnsupportedCriteriaException unless constant
        const_get(constant)
      end
    end

    def args(value)
      args = []
      args << name if name
      args << formatter.call(value)
      args
    end

    attr_reader :name, :formatter
    def initialize(selector = nil, &formatter)
      @name = selector
      @formatter = formatter || proc { |arg| arg }
    end

    XPath = Selector.new(:xpath)
    ID = Selector.new(:id)
    LABEL = Selector.new(:field)

    CSS = Selector.new
    TEXT = Selector.new
    Name = Selector.new do |arg|
      "*[name='#{arg}']"
    end
  end
end
