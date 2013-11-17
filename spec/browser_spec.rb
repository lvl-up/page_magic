require 'spec_helper'

describe PageMagic::Browser do
  let(:app) { Object.new }

  before do
    PageMagic::Browser.instance_variable_set(:@session, nil)
    app.extend PageMagic::Browser
  end

  describe 'default' do
    it 'should be firefox' do
      PageMagic::Browser.default.should == :firefox
    end
  end

  describe 'browser' do
    it 'should return the existing session' do
      session_instance = app.browser
      app.browser.should == session_instance
    end

    it 'should create a session if not already set' do
      new_session = double(:new_session)

      PageMagic.should_receive(:session).with(:firefox).and_return new_session
      app.browser.should == new_session
    end

    it 'should use custom browser' do
      PageMagic.should_receive(:session).with(:custom_browser)

      PageMagic::Browser.default = :custom_browser
      app.browser
    end
  end
end