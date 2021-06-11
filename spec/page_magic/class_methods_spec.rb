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

    context 'block not set' do
      it 'returns a default block' do
        expect(page_class.on_load).to be(described_class::DEFAULT_ON_LOAD)
      end
    end

    context 'block set' do
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
      subject.url(:url)
      expect(page_class.url).to eq(:url)
    end
  end

  describe '#visit' do
    include_context 'webapp fixture'

    subject(:page_class) do
      Class.new.tap do |clazz|
        clazz.extend(described_class)
        clazz.include(PageMagic::InstanceMethods)
      end
    end

    it 'passes all options to create an active session on the registered url' do
      page_class.url '/page1'
      expect(PageMagic).to receive(:session).with(application: rack_app,
                                                  options: {},
                                                  browser: :rack_test,
                                                  url: subject.url).and_call_original

      session = page_class.visit(application: rack_app, options: {}, browser: :rack_test)

      expect(session.title).to eq('page1')
    end
  end
end
