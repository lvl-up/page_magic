module PageMagic

  describe 'Page elements' do
    before :each do
      Capybara.app = Class.new(Sinatra::Base) do
        get '/' do
          <<-HTML
          <label>enter text
          <input id='field_id' name='field_name' class='input_class' type='text' value='filled in'/>
          </label>
          <a id=my_link href='#'>my link</a>
          <button id=my_button href='#'>my button</button>
          HTML
        end
      end

      Capybara.current_session.visit('/')
    end

    describe 'inheriting' do
      include_context :webapp

      it 'lets you create custom elements' do
        custom_element = Class.new(PageMagic::Element) do
          selector css: '.form'

          link :form_link, id: 'form_link'

          def self.name
            'Form'
          end
        end

        page = Class.new do
          include PageMagic
          url '/elements'
          section custom_element
        end

        page = page.new
        page.visit
        page.form.form_link.visible?.should be_true
      end
    end

    it 'should raise an error if a selector has not been specified' do
      expect { PageMagic::Element.new(:name, Object.new, type: :element).browser_element }.to raise_error(PageMagic::UndefinedSelectorException)
    end

    describe '#respond_to?' do
      subject do
        PageMagic::Element.new(:name, Object.new, type: :element, browser_element: double(element_method: '')) do
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

    let!(:page) do
      page_class = Class.new do
        include PageMagic
      end
      page_class.new
    end


    describe '#browser_element' do
      let!(:browser) { double('browser') }

      context 'options supplied to selector' do
        it 'passes them on to the cappybara finder method' do
          options = {key: :value}
          xpath_selector = '//input'
          expect(Capybara.current_session).to receive(:find).with(:xpath, xpath_selector, options)
          PageMagic::Element.new(:my_input, page, type: :text_field, selector: {xpath: xpath_selector}.merge(options)).browser_element
        end
      end

      it 'should find by xpath' do
        element = PageMagic::Element.new(:my_input, page, type: :text_field, selector: {xpath: '//input'}).browser_element
        element.value == 'filled in'
      end

      it 'should locate an element using its id' do
        element = PageMagic::Element.new(:my_input, page, type: :text_field, selector: {id: 'field_id'}).browser_element
        element.value.should == 'filled in'
      end

      it 'should locate an element using its name' do
        element = PageMagic::Element.new(:my_input, page, type: :text_field, selector: {name: 'field_name'}).browser_element
        element.value.should == 'filled in'
      end

      it 'should locate an element using its label' do
        element = PageMagic::Element.new(:my_link, page, type: :link, selector: {label: 'enter text'}).browser_element
        element[:id].should == 'field_id'
      end

      it 'should raise an exception when finding another element using its text' do
        expect { PageMagic::Element.new(:my_link, page, type: :text_field, selector: {text: 'my link'}).browser_element }.to raise_error(PageMagic::UnsupportedSelectorException)
      end

      it 'should locate an element using css' do
        element = PageMagic::Element.new(:my_link, page, type: :link, selector: {css: "input[name='field_name']"}).browser_element
        element[:id].should == 'field_id'
      end

      it 'should return a prefetched value' do
        PageMagic::Element.new(:help, page, type: :link, browser_element: :prefetched_object).browser_element.should == :prefetched_object
      end

      it 'should raise errors for unsupported selectors' do
        expect { PageMagic::Element.new(:my_link, page, type: :link, selector: {unsupported: ''}).browser_element }.to raise_error(PageMagic::UnsupportedSelectorException)
      end

      context 'text selector' do
        it 'should locate a link' do
          element = PageMagic::Element.new(:my_link, page, type: :link, selector: {text: 'my link'}).browser_element
          element[:id].should == 'my_link'
        end

        it 'should locate a button' do
          element = PageMagic::Element.new(:my_button, page, type: :button, selector: {text: 'my button'}).browser_element
          element[:id].should == 'my_button'
        end
      end
    end

    describe '#section?' do
      context 'element definitions exist' do
        subject do
          PageMagic::Element.new(:my_link, :page, type: :link, selector: {text: 'my link'}) do
            element :thing, text: 'text'
          end
        end
        it 'returns true' do
          expect(subject.section?).to eq(true)
        end
      end

      context 'method defined' do
        subject do
          PageMagic::Element.new(:my_link, :page, type: :link, selector: {text: 'my link'}) do
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
          PageMagic::Element.new(:my_link, :page, type: :link, selector: {text: 'my link'})
        end
        it 'returns false' do
          expect(subject.section?).to eq(false)
        end
      end
    end

    describe 'session' do
      it 'should have a handle to the session' do
        page_class = Class.new do
          include PageMagic
        end
        page = page_class.new

        PageMagic::Element.new(:help, page, type: :link, selector: :selector).session.should == page.session
      end
    end

    describe 'hooks' do
      subject do
        PageMagic::Element.new(:my_button, page, type: :button, selector: {id: 'my_button'}) do
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
          PageMagic::Element.new(:my_button, page, type: :button, selector: {id: 'my_button'}) do
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


    context 'tests copied in from section' do
      include_context :webapp

      before :each do
        @elements_page = elements_page.new
        @elements_page.visit
      end

      let!(:elements_page) do
        Class.new do
          include PageMagic
          url '/elements'
          section :form_by_css do
            selector css: '.form'
            link(:link_in_form, text: 'a in a form')
          end

          section :form_by_id do
            selector id: 'form'
            link(:link_in_form, text: 'a in a form')
          end
        end
      end

      describe 'method_missing' do
        it 'should delegate to capybara' do
          @elements_page.form_by_css.visible?.should be(true)
        end

        it 'should throw default exception if the method does not exist on the capybara object' do
          expect { @elements_page.form_by_css.bobbins }.to raise_exception ElementMissingException
        end
      end

      it 'can have elements' do
        @elements_page.form_by_css.link_in_form.visible?.should be_true
      end
    end
  end
end