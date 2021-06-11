# frozen_string_literal: true

RSpec.describe PageMagic::Drivers do
  describe '#find' do
    it 'returns the registered driver' do
      drivers = described_class.new
      expected_driver = PageMagic::Driver.new(:browser_driver)

      drivers.register expected_driver
      expect(drivers.find(:browser_driver)).to eq(expected_driver)
    end
  end

  describe '#load' do
    include_context 'files'

    it 'loads the drivers in the specified path' do
      drivers = described_class.new
      class_definition = <<-RUBY
          class CustomDriver;
            def self.support? browser
              true
            end
          end
      RUBY

      File.write("#{scratch_dir}/custom_driver.rb", class_definition)

      drivers.load(scratch_dir)
      expect(drivers.find(:custom_browser)).to be(::CustomDriver)
    end
  end

  describe '#register' do
    it 'stores the driver' do
      drivers = described_class.new
      expected_driver = PageMagic::Driver.new(:browser_driver)
      drivers.register expected_driver
      expect(drivers.all).to eq([expected_driver])
    end
  end
end
