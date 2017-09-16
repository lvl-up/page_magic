require 'page_magic/driver'
require 'page_magic/utils/string'
module PageMagic
  # class Drivers - creates an object that can be used to hold driver definitions
  # These PageMagic gets the user's chosen driver from this object.
  class Drivers
    def all
      @all ||= []
    end

    # Find a driver definition based on its registered name
    # @param [Symbol] browser registered name of the required browser
    def find(browser)
      all.find { |driver| driver.support?(browser) }
    end

    # Loads drivers defined in files at the given path
    # @param [String] path where the drivers are located
    def load(path = "#{__dir__}/drivers")
      require 'active_support/inflector'

      Dir["#{path}/*.rb"].each do |driver_file|
        require driver_file
        driver_name = File.basename(driver_file)[/(.*)\.rb$/, 1]
        register self.class.const_get(Utils::String.classify(driver_name))
      end
    end

    # Make a driver available for selection when creating calling {PageMagic.session}
    # @param [Driver] driver driver definition
    def register(driver)
      all << driver
    end

    # returns true if this driver instance is equal to the supplied object
    # @param [Object] other subject of equality check
    # @return [Boolean] true if the object is a match
    def ==(other)
      other.respond_to?(:all) && all == other.all
    end
  end
end
