require 'page_magic/driver'
module PageMagic
  # class Drivers - creates an object that can be used to hold driver definitions
  # These PageMagic gets the user's chosen driver from this object.
  class Drivers
    def all
      @all ||= []
    end

    def register(driver)
      all << driver
    end

    def find(browser)
      all.find { |driver| driver.support?(browser) }
    end

    def load(path = "#{__dir__}/drivers")
      require 'active_support/inflector'

      Dir["#{path}/*.rb"].each do |driver_file|
        require driver_file
        driver_name = File.basename(driver_file)[/(.*)\.rb$/, 1]
        register self.class.const_get(driver_name.classify)
      end
    end

    def ==(other)
      other.is_a?(Drivers) && all == other.all
    end
  end
end
