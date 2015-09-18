module Capybara
  module Selenium
    class Driver
      def ==(driver)
        driver.respond_to?(:options) && options == driver.options &&
          driver.respond_to?(:app) && app == driver.app
      end
    end
  end
end
