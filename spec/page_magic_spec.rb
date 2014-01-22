require 'spec_helper'
require 'capybara/rspec'
require 'sinatra/base'

describe 'page magic' do
  include Capybara::DSL

  describe 'class level' do
    let(:app_class) do
      Class.new do
        def call env
          [200, {}, ["hello world!!"]]
        end
      end
    end

    context 'session' do

      it 'should setup a session using the specified browser' do
        Capybara::Session.should_receive(:new).with(:chrome, nil).and_return(:chrome_session)

        session = PageMagic.session(:chrome)
        Capybara.drivers[:chrome].call(nil).should == Capybara::Selenium::Driver.new(nil, browser: :chrome)

        session.raw_session.should == :chrome_session
      end

      it 'should use the Capybara default browser if non is specified' do
        Capybara.default_driver = :rack_test
        session = PageMagic.session
        session.raw_session.mode.should == :rack_test
      end

      it 'should use the supplied Rack application' do
        session = PageMagic.session(application: app_class.new)
        session.raw_session.visit('/')
        session.raw_session.text.should == 'hello world!!'
      end

      it 'should use the rack app with a given browser' do
        session = PageMagic.session(:rack_test, application: app_class.new)
        session.raw_session.mode.should == :rack_test
        session.raw_session.visit('/')
        session.raw_session.text.should == 'hello world!!'
      end

      context 'supported browsers' do
        it 'should support the poltergeist browser' do
          session = PageMagic.session(:poltergeist, application: app_class.new)
          session.raw_session.driver.is_a?(Capybara::Poltergeist::Driver).should be_true
        end

        it 'should support the selenium browser' do
          session = PageMagic.session(:firefox, application: app_class.new)
          session.raw_session.driver.is_a?(Capybara::Selenium::Driver).should be_true
        end
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


    describe 'inheritance' do
      let(:parent_page)  do
        Class.new do
          include PageMagic
          link(:next, :text => "next page")
        end
      end

      let(:child_page) do
        Class.new(parent_page)
      end

      context 'children' do
        it 'should inherit elements defined on the parent class' do
          child_page.element_definitions.should include(:next)
        end

        it 'are added to PageMagic.pages list' do
          PageMagic.pages.should include(child_page)
        end

        it 'should pass on element definitions to their children' do
          grand_child_class = Class.new(child_page)
          grand_child_class.element_definitions.should include(:next)
        end
      end
    end




    it 'can have fields' do
      @page.element_definitions[:next].call(@page).should == PageMagic::Element.new(:next, @page, :button, :text => "next")
    end

    it 'should copy fields on to element' do
      new_page = my_page_class.new
      @page.element_definitions[:next].call(@page).should_not equal(new_page.element_definitions[:next].call(new_page))
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