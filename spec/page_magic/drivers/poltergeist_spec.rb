require 'page_magic/drivers/poltergeist'
module PageMagic
  class Drivers
    describe Poltergeist do
      it "is capybara's poltergeist driver" do
        expect(described_class.build(:app, browser: :poltergeist, options: {})).to be_a(Capybara::Poltergeist::Driver)
      end
    end
  end
end
