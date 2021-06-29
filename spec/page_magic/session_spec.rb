# frozen_string_literal: true

RSpec.describe PageMagic::Session do
  subject(:session) { described_class.new(browser, 'http://base.url') }

  let(:page) do
    Class.new do
      include PageMagic
    end
  end

  let(:browser) do
    rack_application = Class.new do
      def self.call(_env)
        [200, {}, ['ok']]
      end
    end

    Capybara::Session.new(:rack_test, rack_application)
  end

  describe '#current_page' do
    let(:another_page_class) do
      Class.new do
        include PageMagic
      end
    end

    it 'returns the current page' do
      session.visit(page, url: 'http://base.url')
      expect(session.current_page).to be_an_instance_of(page)
    end

    context 'when the page url has changed' do
      it 'returns the mapped page object' do
        session.define_page_mappings '/another_page1' => another_page_class
        browser.visit('/another_page1')
        expect(session.current_page).to be_an_instance_of(another_page_class)
      end
    end
  end

  describe '#current_path' do
    it "returns the browser's current path" do
      browser.visit('/url')
      expect(session.current_path).to eq(browser.current_path)
    end
  end

  describe '#current_url' do
    it "returns the browser's current url" do
      browser.visit('/url')
      expect(session.current_url).to eq(session.current_url)
    end
  end

  describe '#define_page_mappings' do
    context 'when the mapping includes a literal' do
      it 'creates a matcher to contain the specification' do
        session.define_page_mappings path: :page
        expect(session.transitions).to eq(PageMagic::Matcher.new(:path) => :page)
      end
    end

    context 'when the mapping is a matcher' do
      it 'leaves it intact' do
        expected_matcher = PageMagic::Matcher.new(:page)
        session.define_page_mappings expected_matcher => :page
        expect(session.transitions.key(:page)).to be(expected_matcher)
      end
    end
  end

  describe '#execute_script' do
    it 'calls the execute script method on the capybara session' do
      allow(browser).to receive(:execute_script).with(:script).and_return(:result)
      expect(session.execute_script(:script)).to be(:result)
    end

    context 'when the Capybara session does not support #execute_script' do
      let(:browser) { Capybara::Driver::Base.new }

      it 'raises an error' do
        expected_message = described_class::UNSUPPORTED_OPERATION_MSG
        expect { session.execute_script(:script) }.to raise_error(PageMagic::NotSupportedException, expected_message)
      end
    end
  end

  describe '#method_missing' do
    before do
      page.class_eval do
        def my_method
          :called
        end
      end
    end

    it 'delegates to current page' do
      session = described_class.new(browser).visit(page, url: 'http://base.url')
      expect(session.my_method).to be(:called)
    end
  end

  describe '#respond_to?' do
    it 'checks self' do
      session = described_class.new(browser)
      expect(session.respond_to?(:current_url)).to eq(true)
    end

    context 'when method is not on self' do
      before do
        page.class_eval do
          def my_method
            :called
          end
        end
      end

      it 'checks the current page' do
        session = described_class.new(browser)
        session.visit(page, url: '/')
        expect(session.respond_to?(:my_method)).to eq(true)
      end
    end
  end

  describe '#visit' do
    context 'when a page is supplied' do
      it 'sets the current page' do
        session.define_page_mappings '/page' => page
        session.visit(page)
        expect(session.current_page).to be_a(page)
      end

      it 'uses the base url and the path in the page mappings' do
        session = described_class.new(browser, 'http://base.url')
        session.define_page_mappings '/page' => page
        session.visit(page)
        expect(session.current_url).to eq('http://base.url/page')
      end

      it 'raises an error when page no page mappings are found' do
        expect do
          session.visit(page)
        end.to raise_exception PageMagic::InvalidURLException, described_class::URL_MISSING_MSG
      end

      it 'calls the onload hook' do
        on_load_hook_called = false
        page.on_load { on_load_hook_called = true }
        session.visit(page, url: 'http://base.url')
        expect(on_load_hook_called).to eq(true)
      end
    end

    context 'when `url` is supplied' do
      it 'visits that url' do
        expected_url = 'http://base.url/page'
        session.visit(url: expected_url)
        expect(browser.current_url).to eq(expected_url)
      end
    end
  end
end
