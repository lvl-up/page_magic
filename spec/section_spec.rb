require 'spec_helper'

describe 'sections' do

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
      Class.new(PageMagic::Element) do
        #extend PageMagic::Section
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





end