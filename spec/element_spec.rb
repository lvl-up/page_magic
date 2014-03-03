require 'sinatra'

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

  describe 'construction' do

    let(:page_section_class) do
      Class.new(PageMagic::Element)
    end

    let(:selector) { {css: '.class_name'} }

    let!(:browser) { double('browser', find: :browser_element) }
    let!(:parent_page_element) { double('parent_page_element', browser_element: browser) }

  end

  describe 'browser_element' do
    it 'should raise an error if a selector has not been specified' do
      expect { PageMagic::Element.new(:name, Object.new, :type).browser_element }.to raise_error(PageMagic::UndefinedSelectorException)
    end
  end

  describe 'location' do
    let!(:browser) { double('browser') }
    let!(:page) do
      page_class = Class.new do
        include PageMagic
      end
      page_class.new
    end

    it 'should find by xpath' do
      element = PageMagic::Element.new(:my_input, page, :text_field, xpath: '//input').browser_element
      element.value == 'filled in'
    end

    it 'should locate an element using its id' do
      element = PageMagic::Element.new(:my_input, page, :text_field, id: 'field_id').browser_element
      element.value.should == 'filled in'
    end

    it 'should locate an element using its name' do
      element = PageMagic::Element.new(:my_input, page, :text_field, name: 'field_name').browser_element
      element.value.should == 'filled in'
    end


    it 'should locate an element using its label' do
      element = PageMagic::Element.new(:my_link, page, :link, label: 'enter text').browser_element
      element[:id].should == 'field_id'
    end

    it 'should raise an exception when finding another element using its text' do
      expect { PageMagic::Element.new(:my_link, page, :text_field, text: 'my link').browser_element }.to raise_error(PageMagic::UnsupportedSelectorException)
    end

    it 'should locate an element using css' do
      element = PageMagic::Element.new(:my_link, page, :link, css: "input[name='field_name']").browser_element
      element[:id].should == 'field_id'
    end


    it 'should return a prefetched value' do
      PageMagic::Element.new(:help, page, :link, :prefetched_object).browser_element.should == :prefetched_object
    end

    it 'should raise errors for unsupported selectors' do
      expect { PageMagic::Element.new(:my_link, page, :link, unsupported: "").browser_element }.to raise_error(PageMagic::UnsupportedSelectorException)
    end

    context 'text selector' do
      it 'should locate a link' do
        element = PageMagic::Element.new(:my_link, page, :link, text: 'my link').browser_element
        element[:id].should == 'my_link'
      end

      it 'should locate a button' do
        element = PageMagic::Element.new(:my_button, page, :button, text: 'my button').browser_element
        element[:id].should == 'my_button'
      end
    end
  end

  describe 'session' do
    it 'should have a handle to the session' do
      page_class = Class.new do
        include PageMagic
      end
      page = page_class.new

      PageMagic::Element.new(:help, page, :link, :selector).session.should == page.session
    end
  end


  context 'tests coppied in from section' do
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
        expect { @elements_page.form_by_css.bobbins }.to raise_exception NoMethodError
      end
    end

    it 'can have elements' do
      @elements_page.form_by_css.link_in_form.visible?.should be_true
    end
  end


end
