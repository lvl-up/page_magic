# frozen_string_literal: true

RSpec.describe PageMagic::ClassMethods do
  describe '#load' do
    subject(:page_class) do
      Class.new.tap do |clazz|
        clazz.extend(described_class)
        clazz.include(PageMagic::InstanceMethods)
      end
    end

    let(:page_title) { 'page title' }
    let(:page_source) do
      <<-HTML
          <html>
            <head><title>#{page_title}</title></head>
          </html>
      HTML
    end

    it 'returns an instance using that source' do
      expect(page_class.load(page_source).title).to eq(page_title)
    end
  end

  describe 'on_load' do
    subject(:page_class) do
      Class.new.tap do |clazz|
        clazz.extend(described_class)
      end
    end

    context 'when a block is not set' do
      it 'returns a default block' do
        expect(page_class.on_load).to be(described_class::DEFAULT_ON_LOAD)
      end
    end

    context 'when a block is set' do
      it 'returns that block' do
        expected_block = proc {}
        page_class.on_load(&expected_block)
        expect(page_class.on_load).to be(expected_block)
      end
    end
  end

  describe '#url' do
    subject(:page_class) do
      Class.new.tap do |clazz|
        clazz.extend(described_class)
      end
    end

    it 'get/sets a value' do
      page_class.url(:url)
      expect(page_class.url).to eq(:url)
    end
  end

  describe '#visit' do
    subject(:page_class) do
      Class.new.tap do |clazz|
        clazz.extend(described_class)
        clazz.include(PageMagic::InstanceMethods)
        clazz.url ''
      end
    end

    let(:rack_app) do
      Class.new do
        def self.call(_env)
          [200, {}, ['<html><head><title>page1</title></head></html>']]
        end
      end
    end

    it 'passes all options to create an active session on the registered url' do
      allow(PageMagic).to receive(:session).and_call_original

      page_class.visit(application: rack_app, options: {}, browser: :rack_test)

      expected_option = { application: rack_app, options: {}, browser: :rack_test, url: page_class.url }
      expect(PageMagic).to have_received(:session).with(expected_option)
    end

    it 'returns a session' do
      session = page_class.visit(application: rack_app, options: {}, browser: :rack_test)
      expect(session).to be_kind_of(PageMagic::Session)
    end
  end
end
