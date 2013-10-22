require 'spec_helper'
require 'page_object'

describe 'Element Context' do

  include_context :webapp

  let!(:page1) do
    Class.new do
      include PageObject
      url '/page1'
      link(:next, :text => "next page")
    end
  end

  let!(:elements_page) do
    Class.new do
      include PageObject
      url '/elements'
      link(:a_link, :text => "a link")
    end
  end

  let!(:browser) do
    double('browser')
  end

  it 'should raise an error if an element is not found' do
    expect { PageObject::ElementContext.new(page1.new(browser), browser, self).missing_thing }.to raise_error PageObject::ElementMissingException
  end

  it 'should attempt to execute method on page object it is defined' do
    page1.class_eval do
      def page_method
        :called
      end
    end

    PageObject::ElementContext.new(page1.new(browser), browser, self).page_method.should == :called
  end


  describe 'location' do

  end

  describe 'interaction with page elements' do

  end

  describe 'retrieving elements' do
    it 'should give the capybara object' do
      page = elements_page.new
      page.visit

      element = PageObject::ElementContext.new(page, page.browser, self).a_link
      element.text.should == 'a link'
    end
  end

  describe 'actions' do
    it 'should click the element' do
      page = page1.new
      page.visit

      PageObject::ElementContext.new(page, page.browser, self).click_next
      page.current_path.should == '/page2'
      page.text.should == 'page 2 content'
    end
  end


  describe 'accessing page sections' do
    it 'should go through page sections' do

      elements_page.class_eval do
        section :form do
          selector css: '.form'
        end
      end

      page = elements_page.new
      page.visit

      PageObject::ElementContext.new(page, page.browser, self).form.should_not be_nil
    end
  end

  describe 'accessing inline page sections' do
    it 'should go through inline page sections' do

      elements_page.class_eval do
        section :form do
          selector css: 'form'

          def locate arg
            inline_section(@browser_element) do
              link(:submit, text: 'a in a form')
            end
          end
        end
      end

      page = elements_page.new
      page.visit

      PageObject::ElementContext.new(page, page.browser, self).form.submit.should_not be_nil
    end
  end

  describe 'hooks' do

    it 'should execute a before and after action that gives access to the browser' do

      page = elements_page.new
      page.visit

      selector = {text: 'a link'}
      browser = page.browser
      browser.should_receive(:call_in_before_hook)
      browser.should_receive(:call_in_after_before_hook)


      elements_page.link(:create, selector) do
        before do |page_browser|
          page_browser.call_in_before_hook
        end

        after do |page_browser|
          page_browser.call_in_after_before_hook
        end
      end

      PageObject::ElementContext.new(page, page.browser, self).create.click
    end

  end

  it 'should not copy its own fields on to the element contexts it returns as these could lead to conflicts' do

    element_context = PageObject::ElementContext.new(page1.new(browser), browser, self)
    PageObject::ElementContext.new(element_context, browser, self).element_definitions.empty?.should == true
  end

end
