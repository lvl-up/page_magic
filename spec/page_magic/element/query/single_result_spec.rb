# frozen_string_literal: true

RSpec.describe PageMagic::Element::Query::SingleResult do
  describe '#find' do
    context 'when more than one result is returned' do
      it 'raises an error' do
        element = PageMagic::Element.load('<a></a><a></a>')
        query = described_class.new('a')
        expected_message = 'Ambiguous match, found 2 elements matching visible css "a"'
        expect { query.execute(element) }.to raise_error PageMagic::AmbiguousQueryException, expected_message
      end
    end

    it 'returns the result of the capybara query' do
      element = PageMagic::Element.load('<a>link</a>')
      query = described_class.new('a')
      result = query.execute(element)
      expect(result.text).to eq('link')
    end
  end
end
