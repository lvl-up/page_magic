# frozen_string_literal: true

RSpec.describe PageMagic::Utils::URL do
  describe '#concat' do
    it 'produces compound url' do
      expect(described_class.concat('http://base.url/', '/home')).to eq('http://base.url/home')
    end
  end
end
