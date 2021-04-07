# frozen_string_literal: true

PageMagic::Drivers::Selenium = PageMagic::Driver.new(:chrome, :firefox) do |app, options, browser|
  require 'watir'
  Capybara::Selenium::Driver.new(app, **options.dup.merge(browser: browser))
end
