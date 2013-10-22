require 'spec_helper'

describe PageObject::Site do
  context 'visit' do
    it 'should setup a session using the specified browser' do
      Capybara::Session.should_receive(:new).with(:chrome,nil).and_return(:chrome_session)

      session = PageObject::Site.visit(browser: :chrome)
      Capybara.drivers[:chrome].call(nil).should == Capybara::Selenium::Driver.new(nil, browser: :chrome)

      session.browser.should == :chrome_session
    end

    it 'should use the Capybara default browser if non is specified' do
      Capybara.default_driver = :rack_test
      session = PageObject::Site.visit
      session.browser.mode.should == :rack_test
    end
  end
end