# frozen_string_literal: true

RSpec.describe PageMagic::Element::Query::MultipleResults do
  include_context 'webapp fixture'

  describe '#find' do
    context 'multiple results found' do
      it 'returns an array' do
        subject = described_class.new('a')
        result = subject.execute(page.browser)
        expect(result.size).to eq(2)
      end
    end
  end
end
