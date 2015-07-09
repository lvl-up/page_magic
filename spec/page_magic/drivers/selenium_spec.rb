require 'page_magic/drivers/selenium'
module PageMagic
  class Drivers
    describe Selenium do
      it 'is selenium' do
        expect(described_class.build(:app, browser: :selenium, options:{})).to be_a(Capybara::Selenium::Driver)
      end
    end
  end
end