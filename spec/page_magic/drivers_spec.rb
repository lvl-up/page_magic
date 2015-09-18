require 'page_magic/drivers'

module PageMagic
  describe Drivers do
    subject { described_class.new }
    let(:expected_driver) { Driver.new(:browser_driver) }
    describe '#register' do
      it 'stores the driver' do
        subject.register expected_driver
        expect(subject.all).to eq([expected_driver])
      end
    end

    describe '#find' do
      it 'returns the registered driver' do
        subject.register expected_driver
        expect(subject.find(:browser_driver)).to eq(expected_driver)
      end
    end

    describe '#load' do
      include_context :files
      it 'loads the drivers in the specified path' do
        class_definition = <<-RUBY
          class CustomDriver;
            def self.support? browser
              true
            end
          end
        RUBY

        File.write("#{scratch_dir}/custom_driver.rb", class_definition)

        subject.load(scratch_dir)
        expect(subject.find(:custom_browser)).to be(::CustomDriver)
      end
    end
  end
end
