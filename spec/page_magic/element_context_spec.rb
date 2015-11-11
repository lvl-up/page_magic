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

    let!(:session) do
      double('session', raw_session: double('browser'))
    end

    describe '#find' do
      # context 'options supplied to selector' do
      #   it 'passes them on to the cappybara finder method' do
      #     options = {count: 1}
      #     xpath_selector = '//div/input'
      #     expect(page.session.raw_session).to receive(:find).with(:xpath, xpath_selector, options)
      #     described_class.new(type: :text_field,
      #                         selector: {xpath: xpath_selector}.merge(options)).init(page)
      #   end
      # end
      #
      # it 'should find by xpath' do
      #   element = described_class.new(type: :text_field,
      #                                 selector: {xpath: '//div/label/input'}).init(page)
      #   expect(element.value).to eq('filled in')
      # end
      #
      # it 'should locate an element using its id' do
      #   element = described_class.new(type: :text_field,
      #                                 selector: {id: 'field_id'}).init(page)
      #   expect(element.value).to eq('filled in')
      # end
      #
      # it 'should locate an element using its name' do
      #   element = described_class.new(type: :text_field,
      #                                 selector: {name: 'field_name'}).init(page)
      #   expect(element.value).to eq('filled in')
      # end
      #
      # it 'should locate an element using its label' do
      #   element = described_class.new(type: :text_field,
      #                                 selector: {label: 'enter text'}).init(page)
      #   expect(element[:id]).to eq('field_id')
      # end
      #
      # it 'should locate an element using css' do
      #   element = described_class.new(type: :text_field,
      #                                 selector: {css: "input[name='field_name']"}).init(page)
      #   expect(element[:id]).to eq('field_id')
      # end
      #
      # it 'should return a prefetched value' do
      #   element = described_class.new(type: :link, prefetched_browser_element: :prefetched_object)
      #   expect(element.init(page)).to eq(:prefetched_object)
      # end
      #
      # it 'should raise errors for unsupported criteria' do
      #   element = described_class.new(type: :link,
      #                                 selector: {unsupported: ''})
      #
      #   expect { element.init(page) }.to raise_error(PageMagic::UnsupportedCriteriaException)
      # end
      #
      # context 'text selector' do
      #   it 'should locate a link' do
      #     element = described_class.new(type: :link,
      #                                   selector: {text: 'link in a form'}).init(page)
      #     expect(element[:id]).to eq('form_link')
      #   end
      #
      #   it 'should locate a button' do
      #     element = described_class.new(type: :button, selector: {text: 'a button'}).init(page)
      #     expect(element[:id]).to eq('form_button')
      #   end
      # end
    end

    describe '#method_missing' do
      let(:page) do
        elements_page.visit(application: rack_app).current_page
      end

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
