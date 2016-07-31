module PageMagic
  class Element
    describe Query do
      include_context :webapp_fixture

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
            QueryBuilder.find(:link).build(css: 'wrong')
          end

          it 'raises an error' do
            expected_message = Element::Query::ELEMENT_NOT_FOUND_MSG % 'css "wrong"'
            expect { subject.execute(page.browser) }.to raise_exception(ElementMissingException, expected_message)
          end
        end

        it 'returns the result of the capybara query' do
          query = QueryBuilder.find(:link).build(id: 'form_link')
          result = query.execute(page.browser)
          expect(result.size).to eq(1)
          expect(result.first.text).to eq('link in a form')
        end
      end
    end
  end
end
