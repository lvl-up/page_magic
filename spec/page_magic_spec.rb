require 'page_magic'

describe PageMagic do
  subject do
    Class.new { include PageMagic }
  end

  describe '.included' do
    it 'gives a method for defining the url' do
      subject.url :url
      expect(subject.url).to eq(:url)
    end

    it 'lets you define elements' do
      expect(subject).to be_a(PageMagic::Elements)
    end
  end

  describe '.inherited' do
    let(:parent_page) do
      Class.new do
        include PageMagic
        link(:next, text: 'next page')
      end
    end

    let(:child_page) do
      Class.new(parent_page)
    end

    context 'children' do
      it 'should inherit elements defined on the parent class' do
        expect(child_page.element_definitions).to include(:next)
      end

      it 'should pass on element definitions to their children' do
        grand_child_class = Class.new(child_page)
        expect(grand_child_class.element_definitions).to include(:next)
      end
    end
  end

  describe '::drivers' do
    it 'returns loaded drivers' do
      expected_drivers = described_class::Drivers.new.tap(&:load)

      expect(described_class.drivers).to eq(expected_drivers)
    end
  end

  describe '::session' do
    let(:url) { 'http://url.com/' }
    let(:application) { rack_application.new }

    before do
      allow_any_instance_of(Capybara::Selenium::Driver).to receive(:visit)
    end

    it "defaults to capybara's default session " do
      Capybara.default_driver = :rack_test
      expect(subject.new.browser.mode).to eq(:rack_test)
    end

    context 'specifying the browser' do
      it 'loads the correct driver' do
        session = described_class.session(application: rack_application.new, browser: :firefox, url: :url)
        expect(session.raw_session.driver).to be_a(Capybara::Selenium::Driver)
      end
    end

    include_context :rack_application
    it 'sets the base url for the session' do
      session = described_class.session(application: application, url: url)
      expect(session.current_url).to eq(url)
    end

    context 'specifying a rack application' do
      it 'configures capybara to run against the app' do
        session = described_class.session(application: application, url: url)
        expect(session.raw_session.app).to be(application)
      end
    end

    context 'specifying options' do
      it 'passes the options to the browser driver' do
        options = { option: :config }
        session = described_class.session(options: options, browser: :chrome, url: url)

        expect(session.raw_session.driver.options).to include(options)
      end
    end

    context 'driver for browser not found' do
      it 'raises an error' do
        expected_exception = described_class::UnspportedBrowserException
        expect { described_class.session(browser: :invalid, url: url) }.to raise_exception expected_exception
      end
    end
  end
end
