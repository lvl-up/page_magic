module PageMagic
  class Drivers
    RackTest = Driver.new(:rack_test) do |app, options|
      Capybara::RackTest::Driver.new(app, options)
    end
  end
end
