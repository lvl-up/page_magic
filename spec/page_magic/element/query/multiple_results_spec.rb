# frozen_string_literal: true

RSpec.describe PageMagic::Element::Query::MultipleResults do
  describe '#find' do
    context 'when multiple results found' do
      it 'returns an array' do
        element = PageMagic::Element.load('<a></a><a></a>')
        subject = described_class.new('a')
        result = subject.execute(element)
        expect(result.size).to eq(2)
      end
    end
  end
end
