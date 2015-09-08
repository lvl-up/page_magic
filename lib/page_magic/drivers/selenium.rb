module PageMagic
  class Drivers
    Selenium = Driver.new(:chrome, :firefox) do
      require 'watir-webdriver'
      Capybara::Selenium::Driver
    end
  end
end
