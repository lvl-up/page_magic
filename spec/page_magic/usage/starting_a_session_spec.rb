describe 'PageMagic.session' do
  let(:app_class) do
    Class.new do
      def call(_env)
        [200, {}, ['hello world!!']]
      end
    end
  end

  def registered_driver(browser)
    Capybara.drivers[browser].call(nil)
  end

  context 'specificying a browser' do
    it 'loads the driver for the specified browser' do
      session = PageMagic.session(browser: :firefox)
      session.raw_session.driver.is_a?(Capybara::Selenium::Driver).should be_true
    end
  end

  context 'testing against rack applications' do
    it 'requires the app to be supplied' do
      session = PageMagic.session(application: app_class.new)
      session.raw_session.visit('/')
      session.raw_session.text.should == 'hello world!!'
    end

    it 'can run against an rack application using a particular browser' do
      session = PageMagic.session(browser: :rack_test, application: app_class.new)
      session.raw_session.mode.should == :rack_test
      session.raw_session.visit('/')
      session.raw_session.text.should == 'hello world!!'
    end
  end
end
