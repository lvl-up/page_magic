module PageMagic
  class Driver
    attr_reader :supported_browsers, :handler
    def initialize(*supported_browsers, &block)
      @handler = block
      @supported_browsers = supported_browsers
    end

    def support? browser
      supported_browsers.include?(browser)
    end

    def build(app, browser:, options:{})
      options[:browser] = browser
      driver_clazz = handler.call
      driver_clazz.new(app, options)
    end
  end
end