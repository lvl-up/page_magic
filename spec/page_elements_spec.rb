require 'spec_helper'
require 'page_magic'

describe PageMagic::PageElements do


  let(:page_elements) do
    page_element = Class.new do
      extend(PageMagic::PageElements)
    end
  end

  let(:selector) { {id: 'id'} }
  let(:browser_element) { double('browser_element') }


  describe 'adding elements' do

    context 'using a selector' do
      it 'should add an element' do
        page_elements.text_field :name, selector
        page_elements.elements(browser_element).first.should == PageMagic::PageElement.new(:name, :text_field, selector)
      end

      it 'should return your a copy of the core definition' do
        page_elements.text_field :name, selector
        page_elements.elements(browser_element).first.should_not equal(page_elements.elements(browser_element).first)
      end
    end

    context 'passing in a prefetched watir object' do
      it 'should create a page element with the prefetched watir object as the core browser object' do
        watir_element = double('watir_element')
        page_elements.text_field :name, watir_element
        page_elements.elements(browser_element).first.locate.should == watir_element
      end
    end

  end

  context 'section' do

    let!(:section_class) do
      Class.new do
        extend PageMagic::PageSection

        def == object
          object.class.is_a?(PageMagic::PageSection) &&
              object.name == self.name
        end
      end
    end

    context 'selector' do

      it 'can be an id' do

      end

      it 'can be css' do

      end
    end

    context 'using a class as a definition' do
      it 'should add a section' do
        page_elements.section section_class, :page_section, selector
        page_elements.elements(browser_element).first.should == section_class.new(browser_element, :page_section, selector)
      end
    end

    context 'using a block to define a section inline' do

      context 'browser_element' do
        before :each do
          @browser, @element = double('browser'), double('element')
          @browser.should_receive(:find).with(:css, :selector).and_return(@element)
        end

        it 'should be assigned when selector is passed to section method' do
          element = @element

          page_elements.section :page_section, css: :selector do
            browser_element.should == element
          end

          page_elements.elements(@browser, nil)
        end

        it 'should be assigned when selector is defined in the block passed to the section method' do
          element = @element

          page_elements.section :page_section do
            browser_element.should == nil
            selector css: :selector
            browser_element.should == element
          end

          page_elements.elements(@browser, nil)
        end
      end

      it 'should raise an exception if the selector is not passed' do
        arg, browser, element = {}, double('browser'), double('element')

        page_elements.section :page_section, nil do
        end

        expect { page_elements.elements(browser, arg) }.to raise_error(PageMagic::PageSection::UndefinedSelectorException)
      end

      it 'should add a section' do
        page_elements.section :page_section do
          selector id: 'id'
          link(:hello, text: 'world')
        end

        page_elements.elements(@browser_element).first.elements(@browser_element).first.should == PageMagic::PageElement.new(:page_section, @browser_element)
      end

      it 'should pass args through to the block' do
        page_elements.section :page_section, css: '.blah' do |arg|
          arg[:passed_through] = true
        end

        arg, browser = {}, double('browser', find: :browser_element)
        page_elements.elements(browser, arg)
        arg[:passed_through].should be_true
      end

    end

    it 'should give the browser element to it' do
      page_elements.section section_class, :page_section, selector
      browser_element = double('browser_element')
      page_section = page_elements.elements(browser_element).first
      page_section.instance_variable_get(:@browser_element).should == browser_element
    end

    it 'should return your a copy of the core definition' do
      page_elements.section section_class, :page_section, selector
      page_elements.elements(browser_element).first.should_not equal(page_elements.elements(browser_element).first)
    end
  end

  describe 'restrictions' do
    it 'should not allow method names that match element names' do
      expect do
        page_elements.class_eval do
          link(:hello, text: 'world')

          def hello;
          end
        end
      end.to raise_error(PageMagic::PageElements::InvalidMethodNameException)
    end

    it 'should not allow element names that match method names' do
      expect do
        page_elements.class_eval do
          def hello;
          end

          link(:hello, text: 'world')
        end
      end.to raise_error(PageMagic::PageElements::InvalidElementNameException)
    end

    it 'should not allow duplicate element names' do
      expect do
        page_elements.class_eval do
          link(:hello, text: 'world')
          link(:hello, text: 'world')
        end
      end.to raise_error(PageMagic::PageElements::InvalidElementNameException)
    end

    it 'should not evaluate the elements when applying naming checks' do
      page_elements.class_eval do
        link(:link1, :selector) do
          fail("should not have been evaluated")
        end
        link(:link2, :selector)
      end
    end
  end
end