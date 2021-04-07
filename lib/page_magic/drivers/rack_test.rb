# frozen_string_literal: true

PageMagic::Drivers::RackTest = PageMagic::Driver.new(:rack_test) do |app, options|
  Capybara::RackTest::Driver.new(app, **options)
end
