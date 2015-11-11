module PageMagic
  describe ElementContext do
    include_context :webapp_fixture

    let!(:elements_page) do
      Class.new do
        include PageMagic
        url '/elements'
        link(:a_link, text: 'a link')
      end
    end

    let(:page) do
      elements_page.visit(application: rack_app).current_page
    end

    subject do
      described_class.new(page)
    end

    let!(:session) do
      double('session', raw_session: double('browser'))
    end

    describe '#find' do
      context 'options supplied to selector' do
        it 'passes them on to the cappybara finder method' do
          options = { count: 1 }
          xpath_selector = '//div/input'
          expect(page.browser_element).to receive(:find).with(:xpath, xpath_selector, count: 1).and_call_original
          expect(subject.find({ xpath: xpath_selector }, :text_field, options).value).to eq('a button')
        end
      end

      it 'builds a query to run against the browser' do
        options = {}
        selector = { xpath: '//div/input' }
        expect(Element::Query).to receive(:find).with(:text_field).and_call_original
        expect(Element::Query::TEXT_FIELD).to receive(:build).with(selector, options).and_call_original
        expect(subject.find(selector, :text_field, options).value).to eq('a button')
      end
    end

    describe '#method_missing' do
      context 'method is a element defintion' do
        it 'returns the sub page element' do
          element = described_class.new(page).a_link
          expect(element.text).to eq('a link')
        end

        it 'does not evaluate any of the other definitions' do
          elements_page.class_eval do
            link(:another_link, :selector) do
              fail('should not have been evaluated')
            end
          end

          described_class.new(page).a_link
        end
      end

      context 'method found on page_element' do
        it 'calls page_element method' do
          elements_page.class_eval do
            def page_method
              :called
            end
          end

          expect(described_class.new(page).page_method).to eq(:called)
        end
      end
    end

    describe '#respond_to?' do
      subject do
        described_class.new(elements_page.new(session))
      end
      it 'checks against the names of the elements passed in' do
        expect(subject.respond_to?(:a_link)).to eq(true)
      end
    end
  end
end
