require 'spec_helper'

describe PageMagic::Section do

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

  context 'class level' do
    let(:section) do
      Class.new do
        extend PageMagic::Section
      end
    end

    describe 'selector' do
      before do
        section.parent_browser_element = @elements_page.browser
      end

      it 'should find by id' do
        section.selector id: 'form'
        section.browser_element[:id].should == 'form'
      end

      it 'should find by css' do
        section.selector css: '.form'
        section.browser_element[:id].should == 'form'
      end

      it 'should find by xpath' do
        section.selector xpath: '//div'
        section.browser_element[:id].should == 'form'
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


  describe 'construction' do

    let(:page_section_class) do
      page_section_class = Class.new do
        extend PageMagic::Section
      end
      page_section_class.stub(:name).and_return('PageSection')
      page_section_class
    end

    let(:selector) { {css: '.class_name'} }

    let!(:browser) { double('browser', find: :browser_element) }
    let!(:parent_page_element){ double('parent_page_element', browser_element: browser)}

    context 'selector' do
      it 'should use the class defined selector if one is not given to the constructor' do
        page_section_class.selector selector
        page_section_class.new(parent_page_element).selector.should == selector
      end

      it 'should raise an error if a class selector is not defined and one is not given to the constructor' do
        expect { page_section_class.new(parent_page_element) }.to raise_error(PageMagic::Section::UndefinedSelectorException)
      end
    end

    context 'name' do
      it 'should default to the name of the class if one is not supplied' do
        page_section_class.selector selector
        page_section_class.new(parent_page_element).name.should == :page_section
      end
    end
  end
end