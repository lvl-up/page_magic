require 'spec_helper'
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

  describe 'location' do
    let!(:browser) { double('browser') }
    let!(:page) do
      page_class = Class.new do
        include PageMagic
      end
      page_class.new
    end

    it 'should locate an element using its id' do
      element = PageMagic::Element.new(:my_input, page, :text_field, id: 'field_id').locate
      element.value == 'filled in'
    end

    it 'should locate an element using its name' do
      element = PageMagic::Element.new(:my_input, page, :text_field, name: 'field_name').locate
      element.value == 'filled in'
    end


    it 'should locate an element using its label' do
      element = PageMagic::Element.new(:my_link, page, :link, label: 'enter text').locate
      element[:id].should == 'field_id'
    end

    it 'should raise an exception when finding another element using its text' do
      expect { PageMagic::Element.new(:my_link, page, :text_field, text: 'my link').locate }.to raise_error(PageMagic::UnsupportedSelectorException)
    end

    it 'should locate an element using css' do
      element = PageMagic::Element.new(:my_link, page, :link, css: "input[name='field_name']").locate
      element[:id].should == 'field_id'
    end



    it 'should return a prefetched value' do
      PageMagic::Element.new(:help, page, :link, :prefetched_object).locate.should == :prefetched_object
    end

    it 'should raise errors for unsupported selectors' do
      expect { PageMagic::Element.new(:my_link, page, :link, unsupported: "").locate }.to raise_error(PageMagic::UnsupportedSelectorException)
    end

    context 'text selector' do
      it 'should locate a link' do
        element = PageMagic::Element.new(:my_link, page, :link, text: 'my link').locate
        element[:id].should == 'my_link'
      end

      it 'should locate a button' do
        element = PageMagic::Element.new(:my_button, page, :button, text: 'my button').locate
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
end
