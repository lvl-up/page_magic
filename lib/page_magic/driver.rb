module PageMagic
  # class Driver - instances are factories for drivers used by PageMagic
  class Driver
    attr_reader :supported_browsers, :handler
    # Creates a driver definition
    # @example
    #  Driver.new do |rack_application, options|
    #    require 'capybara/driver_class'
    #    Capybara::Driver::Class.new(app, options)
    #  end
    # @yield[rack_application, options, browser_name]
    # @yieldparam [Object] rack_application rack compatible application
    # @yieldparam [Hash] options hash containing driver specific options
    # @yieldparam [Symbol] browser_name the name of the required browser name
    # @param [*Symbol] supported_browsers list of browsers names. These are the names that
    #  you will refer to them by when creating a session
    # @yieldreturn [Object] Capybara compliant driver
    def initialize(*supported_browsers, &block)
      @handler = block
      @supported_browsers = supported_browsers
    end

    # Build a new driver instance based on this definition
    # @param [Object] app - rack compatible application
    # @param [Symbol] browser name of required browser
    # @param [Hash] options driver specific options
    # @return [Object] Capybara compliant driver instance
    def build(app, browser:, options:{})
      handler.call(app, options, browser)
    end

    # Determines if the given browser name is supported by this driver definition
    # @param [Symbol] browser name of browser
    # @return [Boolean] true if definition supports the given driver name
    def support?(browser)
      supported_browsers.include?(browser)
    end
  end
end
