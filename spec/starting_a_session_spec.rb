require 'spec_helper'
describe 'PageMagic.session' do
  let(:app_class) do
    Class.new do
      def call env
        [200, {}, ["hello world!!"]]
      end
    end
  end


  it 'sets up a session using the specified browser' do
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