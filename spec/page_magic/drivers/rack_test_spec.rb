# frozen_string_literal: true

require 'page_magic/drivers/rack_test'
module PageMagic
  class Drivers
    describe RackTest do
      it "is capybara's rack test driver" do
        driver = described_class.build(:app, browser: :rack_test, options: {})
        expect(driver).to be_a(Capybara::RackTest::Driver)
      end
    end
  end
end
