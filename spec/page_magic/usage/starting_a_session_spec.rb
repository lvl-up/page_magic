require 'spec_helper'
describe 'PageMagic.session' do
  let(:app_class) do
    Class.new do
      def call env
        [200, {}, ["hello world!!"]]
      end
    end
  end

  def registered_driver browser
    Capybara.drivers[browser].call(nil)
  end

  context 'using a symbol as a parameter' do
    it 'sets up a session using the specified browser' do
      Capybara::Session.should_receive(:new).with(:chrome, nil).and_return(:chrome_session)

      session = PageMagic.session(:chrome)

      registered_driver(:chrome).should == Capybara::Selenium::Driver.new(nil, browser: :chrome)

      session.raw_session.should == :chrome_session
    end

    context 'browsers' do
      it 'supports poltergeist' do
        session = PageMagic.session(:poltergeist, application: app_class.new)
        session.raw_session.driver.is_a?(Capybara::Poltergeist::Driver).should be_true
      end

      it 'supports selenium' do
        session = PageMagic.session(:firefox, application: app_class.new)
        session.raw_session.driver.is_a?(Capybara::Selenium::Driver).should be_true
      end
    end
  end

  context 'defaulting the browser used from PageMagic sessions' do
    it "uses what ever Capybara's default_driver is set to" do
      Capybara.default_driver = :rack_test
      session = PageMagic.session
      session.raw_session.mode.should == :rack_test
    end
  end

  context 'testing against rack applications' do

    it 'requires the app to be supplied' do
      session = PageMagic.session(application: app_class.new)
      session.raw_session.visit('/')
      session.raw_session.text.should == 'hello world!!'
    end

    it 'can run against an rack application using a particular browser' do
      session = PageMagic.session(:rack_test, application: app_class.new)
      session.raw_session.mode.should == :rack_test
      session.raw_session.visit('/')
      session.raw_session.text.should == 'hello world!!'
    end
  end

end