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

    describe '#method_missing' do
      let(:page) do
        elements_page.visit(application: rack_app).current_page
      end

      context 'neither a method or page element are defined' do
        it 'raises an error' do
          expect { described_class.new(page).missing_thing }.to raise_error ElementMissingException
        end
      end

      context 'method is a element defintion' do
        it 'returns the sub page element' do
          element = described_class.new(page).a_link
          # TODO: - returns the capybara object. maybe we should think about wrapping this.
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
