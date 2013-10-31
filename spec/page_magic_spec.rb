require 'spec_helper'

describe 'page magic' do

  describe 'class level' do
    context 'session' do
      it 'should setup a session using the specified browser' do
        Capybara::Session.should_receive(:new).with(:chrome,nil).and_return(:chrome_session)

        session = PageMagic.session(:chrome)
        Capybara.drivers[:chrome].call(nil).should == Capybara::Selenium::Driver.new(nil, browser: :chrome)

        session.browser.should == :chrome_session
      end

      it 'should use the Capybara default browser if non is specified' do
        Capybara.default_driver = :rack_test
        session = PageMagic.session
        session.browser.mode.should == :rack_test
      end
    end
  end

  describe 'instances' do

    include_context :webapp

    let(:my_page_class) do
      Class.new do
        include PageMagic
        url '/page1'
        link(:next, :text => "next page")
      end
    end

    let(:another_page_class) do
      Class.new do
        include PageMagic
        url '/another_page1'
      end
    end

    before :each do
      @page = my_page_class.new
    end


    describe 'browser integration' do
      it "should use capybara's default session if a one is not supplied" do
        Capybara.default_driver = :rack_test
        my_page_class.new.browser.mode.should == :rack_test
      end
    end

    describe 'visit' do
      it 'should go to the page' do
        @page.visit
        @page.current_path.should == '/page1'
      end
    end

    context 'move_to moves the session object to another page' do
      it 'can take a class' do
        page_magic_session = PageMagic::Session.new(double(:browser))

        existing_page = my_page_class.new page_magic_session
        existing_page.move_to(another_page_class)

        page_magic_session.current_page.should be_a(another_page_class)
      end

      it 'can take the name of the class as a string' do
        page_magic_session = PageMagic::Session.new(double(:browser))
        existing_page = my_page_class.new page_magic_session

        String.should_receive(:new).and_return "String"
        existing_page.move_to("String")
        page_magic_session.current_page.should be_a(String)
      end
    end


    it 'can have fields' do
      @page.elements(@browser).should == [PageMagic::PageElement.new(:click_create, :button, :text => "create user")]
    end

    it 'should copy fields on to element' do
      @page.elements(@browser).first.should_not equal(my_page_class.new(double('session', browser: @browser)).elements(@browser).first)
    end

    it 'gives access to the page text' do
      @page.visit.text.should == 'next page'
    end

    it 'should access a field' do
      @page.visit
      @page.click_next
      @page.text.should == 'page 2 content'
    end

    it 'are registered at class level' do
      PageMagic.instance_variable_set(:@pages, nil)

      page = Class.new { include PageMagic }
      PageMagic.pages.should == [page]
    end
  end
end