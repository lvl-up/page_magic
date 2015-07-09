module PageMagic
  class Drivers
    RackTest = Driver.new(:rack_test) do
      Capybara::RackTest::Driver
    end
  end
end