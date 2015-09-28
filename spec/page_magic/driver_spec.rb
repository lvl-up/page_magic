require 'page_magic/driver'

module PageMagic
  describe Driver do
    subject do
      described_class.new :custom_browser
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

      it 'returns the result of the block passed to the driver class constructor' do
        subject = described_class.new(:custom_browser)do
          :driver
        end
        expect(subject.build(:rack_app, browser: :custom_browser, options: :options)).to eq(:driver)
      end

      it 'passes rack app to the handler' do
        subject = described_class.new(:custom_browser) do |app, options, browser|
            expect(app).to eq(:rack_app)
            expect(options).to eq(:options)
            expect(browser).to eq(:browser)
        end

        subject.build(:rack_app, options: :options, browser: :browser)
      end
    end
  end
end
