PageMagic::Drivers::Selenium = PageMagic::Driver.new(:chrome, :firefox) do |app, options, browser|
  require 'watir-webdriver'
  Capybara::Selenium::Driver.new(app, options.dup.merge(browser: browser))
end
