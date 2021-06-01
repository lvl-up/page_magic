# frozen_string_literal: true

RSpec.describe PageMagic::Element::Query do
  include_context 'webapp fixture'

  let(:page) do
    elements_page = Class.new do
      include PageMagic
      url '/elements'
    end
    elements_page.visit(application: rack_app).current_page
  end

  describe '#execute' do
    context 'no results found' do
      subject do
        PageMagic::Element::QueryBuilder.find(:link).build({ css: 'wrong' })
      end

      it 'raises an error' do
        expected_message = 'Unable to find css "wrong"'
        expect do
          subject.execute(page.browser)
        end.to raise_exception(PageMagic::ElementMissingException, expected_message)
      end
    end

    context 'to many results returned' do
      subject do
        PageMagic::Element::QueryBuilder.find(:link).build({ css: 'a' })
      end

      it 'raises an error' do
        expected_message = 'Ambiguous match, found 2 elements matching visible css "a"'
        expect { subject.execute(page.browser) }.to raise_error PageMagic::AmbiguousQueryException, expected_message
      end
    end

    context 'multiple results found' do
      subject do
        PageMagic::Element::QueryBuilder.find(:link).build({ css: 'a' }, options: {}, multiple_results: true)
      end

      it 'returns an array' do
        result = subject.execute(page.browser)
        expect(result).to be_a(Array)
        expect(result.size).to eq(2)
      end
    end

    it 'returns the result of the capybara query' do
      query = PageMagic::Element::QueryBuilder.find(:link).build({ id: 'form_link' })
      result = query.execute(page.browser)
      expect(result.text).to eq('link in a form')
    end
  end
end
