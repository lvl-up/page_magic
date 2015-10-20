module PageMagic
  describe Element do
    include_context :webapp_fixture

    let(:page_class) do
      Class.new do
        include PageMagic
        url '/elements'
      end
    end

    let(:page) do
      page_class.new.tap(&:visit)
    end

    describe 'inheriting' do
      it 'lets you create custom elements' do
        custom_element = Class.new(described_class) do
          text_field :form_field, id: 'field_id'

          def self.name
            'Form'
          end
        end

        page_class.class_eval do
          section custom_element, css: '.form'
        end

        expect(page.form.form_field).to be_visible
      end
    end

    it 'should raise an error if a selector has not been specified' do
      expect { described_class.new(:name, Object.new, type: :element).browser_element }.to raise_error(PageMagic::UndefinedSelectorException)
    end

    describe '#respond_to?' do
      subject do
        described_class.new(:name, Object.new, type: :element, browser_element: double(element_method: '')) do
          element :sub_element, css: '.sub-element'
        end
      end
      it 'checks for methods on self' do
        expect(subject.respond_to?(:session)).to eq(true)
      end

      it 'checks against registered elements' do
        expect(subject.respond_to?(:sub_element)).to eq(true)
      end

      it 'checks for the method of the browser_element' do
        expect(subject.respond_to?(:element_method)).to eq(true)
      end
    end

    describe '#browser_element' do
      let!(:browser) { double('browser') }

      context 'options supplied to selector' do
        it 'passes them on to the cappybara finder method' do
          options = { count: 1 }
          xpath_selector = '//div/input'
          expect(Capybara.current_session).to receive(:find).with(:xpath, xpath_selector, options)
          described_class.new(:my_input, page, type: :text_field, selector: { xpath: xpath_selector }.merge(options)).browser_element
        end
      end

      it 'should find by xpath' do
        element = described_class.new(:my_input, page, type: :text_field, selector: { xpath: '//div/label/input' }).browser_element
        expect(element.value).to eq('filled in')
      end

      it 'should locate an element using its id' do
        element = described_class.new(:my_input, page, type: :text_field, selector: { id: 'field_id' }).browser_element
        expect(element.value).to eq('filled in')
      end

      it 'should locate an element using its name' do
        element = described_class.new(:my_input, page, type: :text_field, selector: { name: 'field_name' }).browser_element
        expect(element.value).to eq('filled in')
      end

      it 'should locate an element using its label' do
        element = described_class.new(:my_link, page, type: :link, selector: { label: 'enter text' }).browser_element
        expect(element[:id]).to eq('field_id')
      end

      it 'should raise an exception when finding another element using its text' do
        expect { described_class.new(:my_link, page, type: :text_field, selector: { text: 'my link' }).browser_element }.to raise_error(PageMagic::UnsupportedSelectorException)
      end

      it 'should locate an element using css' do
        element = described_class.new(:my_link, page, type: :link, selector: { css: "input[name='field_name']" }).browser_element
        expect(element[:id]).to eq('field_id')
      end

      it 'should return a prefetched value' do
        described_class.new(:help, page, type: :link, browser_element: :prefetched_object).browser_element.should == :prefetched_object
      end

      it 'should raise errors for unsupported selectors' do
        expect { described_class.new(:my_link, page, type: :link, selector: { unsupported: '' }).browser_element }.to raise_error(PageMagic::UnsupportedSelectorException)
      end

      context 'text selector' do
        it 'should locate a link' do
          element = described_class.new(:my_link, page, type: :link, selector: { text: 'link in a form' }).browser_element
          expect(element[:id]).to eq('form_link')
        end

        it 'should locate a button' do
          element = described_class.new(:my_button, page, type: :button, selector: { text: 'a button' }).browser_element
          element[:id].should == 'form_button'
        end
      end
    end

    describe '#section?' do
      context 'element definitions exist' do
        subject do
          described_class.new(:my_link, page, type: :button, selector: { text: 'a button' }) do
            element :thing, text: 'text'
          end
        end
        it 'returns true' do
          expect(subject.section?).to eq(true)
        end
      end

      context 'method defined' do
        subject do
          described_class.new(:my_link, :page, type: :link, selector: { text: 'my link' }) do
            def custom_method
            end
          end
        end

        it 'returns true' do
          expect(subject.section?).to eq(true)
        end
      end

      context 'neither method or elements defined' do
        subject do
          described_class.new(:my_link, :page, type: :link, selector: { text: 'my link' })
        end
        it 'returns false' do
          expect(subject.section?).to eq(false)
        end
      end
    end

    describe 'session' do
      it 'should have a handle to the session' do
        expect(described_class.new(:help, page, type: :link, selector: :selector).session).to eq(page.session)
      end
    end

    describe 'hooks' do
      subject do
        described_class.new(:my_button, page, type: :button, selector: { id: 'my_button' }) do
          before do
            call_in_before_hook
          end
        end
      end
      context 'method called in before hook' do
        it 'calls methods on the page element' do
          expect(page.browser).to receive(:find).and_return(double('button', click: true))
          expect(subject).to receive(:call_in_before_hook)
          subject.click
        end
      end

      context 'method called in before hook' do
        subject do
          described_class.new(:my_button, page, type: :button, selector: { id: 'my_button' }) do
            after do
              call_in_after_hook
            end
          end
        end
        it 'calls methods on the page element' do
          expect(page.browser).to receive(:find).and_return(double('button', click: true))
          expect(subject).to receive(:call_in_after_hook)
          subject.click
        end
      end
    end

    describe '#method_missing' do
      before do
        page_class.class_eval do
          section :form_by_css, css: '.form' do
            link(:link_in_form, text: 'a in a form')
          end
        end
      end

      it 'can delegate to capybara' do
        expect(page.form_by_css).to be_visible
      end

      context 'method not on capybara browser element' do
        it 'uses the parent page element' do
          page_class.class_eval do
            def parent_method
              :called
            end
          end
          expect(page.form_by_css.parent_method).to eq(:called)
        end
      end

      context 'no element definition and not a capybara method' do
        it 'throws and exception' do
          expect { page.form_by_css.bobbins }.to raise_exception NoMethodError
        end
      end
    end
  end
end
