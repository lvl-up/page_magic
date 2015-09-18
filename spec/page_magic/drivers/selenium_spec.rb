require 'page_magic/drivers/selenium'
module PageMagic
  class Drivers
    describe Selenium do
      it 'is selenium' do
        driver = described_class.build(:app, browser: :selenium, options: {})
        expect(driver).to be_a(Capybara::Selenium::Driver)
      end
    end
  end
end
