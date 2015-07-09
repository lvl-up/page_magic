require 'page_magic/drivers/rack_test'
module PageMagic
  class Drivers
    describe RackTest do
      it %q{is capybara's rack test driver} do
        expect(described_class.build(:app, browser: :rack_test, options:{})).to be_a(Capybara::RackTest::Driver)
      end
    end
  end
end