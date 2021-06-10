require 'page_magic/element/query/single'

RSpec.describe PageMagic::Element::Query::Single do
  include_context 'webapp fixture'

  let(:page) do
    elements_page = Class.new do
      include PageMagic
      url '/elements'
    end
    elements_page.visit(application: rack_app).current_page
  end

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