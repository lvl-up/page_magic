module PageMagic
  describe ElementContext do
    include_context :webapp_fixture

    let!(:elements_page) do
      Class.new do
        include PageMagic
        url '/elements'
        link(:a_link, text: 'a link')
        link(:prefetched, Object.new)
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

    describe '#method_missing' do
      context 'method is a element defintion' do
        it 'returns the sub page element' do
          element = described_class.new(page).a_link
          expect(element.text).to eq('a link')
        end

        it 'passes arguments through to the element definition' do
          elements_page.link :pass_through, css: 'a' do |args|
            args[:passed_through] = true
          end
          args = {}
          described_class.new(page).pass_through(args)
          expect(args[:passed_through]).to eq(true)
        end

        it 'does not evaluate any of the other definitions' do
          elements_page.class_eval do
            link(:another_link, :selector) do
              fail('should not have been evaluated')
            end
          end

          described_class.new(page).a_link
        end

        context 'more than one match found in the browser' do
          it 'returns an array of element definitions' do
            elements_page.link :links, css: 'a'
            links = described_class.new(page).links
            expect(links.find_all { |e| e.class == Element }.size).to eq(2)
            expect(links.collect(&:text)).to eq(['a link', 'link in a form'])
          end
        end
        context 'no results found' do
          it 'raises an error' do
            elements_page.link :missing, css: 'wrong'
            expected_message = described_class::ELEMENT_NOT_FOUND_MSG % 'css "wrong"'
            expect { described_class.new(page).missing }.to raise_exception(ElementMissingException, expected_message)
          end
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

      context 'element is prefetched' do
        it 'does not call find' do
          expect(subject).not_to receive(:find)
          described_class.new(page).prefetched
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
