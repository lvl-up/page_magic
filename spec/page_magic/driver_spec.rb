require 'page_magic/driver'

module PageMagic
  describe Driver do
    let(:driver_class) do
      Class.new do
        attr_reader :rack_app, :options
        def initialize(rack_app, options)
          @rack_app = rack_app
          @options = options
        end

        def ==(driver)
          driver.rack_app == rack_app && driver.options == options
        end
      end
    end
    subject do
      described_class.new :custom_browser do
        driver_class
      end
    end

    describe '#supports?' do
      context 'browser is in supported browsers' do
        it 'returns true' do
          expect(subject.support?(:custom_browser)).to eq(true)
        end
      end

      context 'browser is not in supported browsers' do
        it 'returns false' do
          expect(subject.support?(:unsupported_browser)).to eq(false)
        end
      end
    end
    describe '#build' do
      it 'adds the browser to the options supplied to the driver' do
        expect(subject.build(:rack_app, browser: :custom_browser, options: {}).options).to eq(browser: :custom_browser)
      end

      it 'creates an instance of the supplied driver' do
        expect(subject.build(:rack_app, browser: :custom_browser, options: {})).to eq(driver_class.new(:rack_app, browser: :custom_browser))
      end
    end
  end
end
