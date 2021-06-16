# frozen_string_literal: true
RSpec.describe PageMagic::Drivers::Selenium do
  subject do
    described_class.build(:app, browser: :selenium, options: {})
  end

  it 'is selenium' do
    expect(subject).to be_a(Capybara::Selenium::Driver)
  end

  it 'sets the browser option' do
    expect(subject.options[:browser]).to be(:selenium)
  end
end
