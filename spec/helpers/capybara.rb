module Capybara
  module Selenium
    class Driver
      def == driver
        driver.respond_to?(:options) && self.options == driver.options &&
            driver.respond_to?(:app) && self.app == driver.app
      end
    end
  end
end