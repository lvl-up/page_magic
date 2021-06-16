# frozen_string_literal: true

RSpec.describe PageMagic::Element::Query::SingleResult do
  include_context 'webapp fixture'

  describe '#find' do
    context 'to many results returned' do
      it 'raises an error' do
        subject = described_class.new('a')
        expected_message = 'Ambiguous match, found 2 elements matching visible css "a"'
        expect { subject.execute(page.browser) }.to raise_error PageMagic::AmbiguousQueryException, expected_message
      end
    end

    it 'returns the result of the capybara query' do
      query = described_class.new(:id, 'form_link')
      result = query.execute(page.browser)
      expect(result.text).to eq('link in a form')
    end
  end
end
