module PageMagic
  class UnsupportedCriteriaException < Exception
  end

  class Selector
    class << self
      def find(name)
        selector = constants.find { |constant| constant.to_s.downcase == name.to_s.downcase }
        fail UnsupportedCriteriaException unless selector
        const_get(selector)
      end
    end

    def build(value)
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

    XPATH = Selector.new(:xpath)
    ID = Selector.new(:id)
    LABEL = Selector.new(:field)

    CSS = Selector.new
    TEXT = Selector.new
    NAME = Selector.new do |arg|
      "*[name='#{arg}']"
    end
  end
end
