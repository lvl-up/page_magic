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

  describe '#define_page_mappings' do
    context 'when the mapping includes a literal' do
      it 'creates a matcher to contain the specification' do
        session.define_page_mappings path: :page
        expect(session.transitions.to_h).to include(PageMagic::Mapping.new(:path) => :page)
      end
    end

    context 'when the mapping is a matcher' do
      it 'leaves it intact' do
        expected_matcher = PageMagic::Mapping.new(:page)
        session.define_page_mappings expected_matcher => :page
        expect(session.transitions.key(:page)).to be(expected_matcher)
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

    context 'when method not on current page' do
      it 'delegates to the capybara session' do
        session = described_class.new(browser).visit(page, url: 'http://base.url')
        expect(session).to have_text('ok')
      end
    end
  end

  describe '#is_a?' do
    context 'when other is a `Capybara::Session`' do
      it 'returns true' do
        expect(described_class.new(browser).is_a?(Capybara::Session)).to eq(true)
      end
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

    context 'when method not on self or the current page' do
      it 'checks the capybara session' do
        session = described_class.new(browser)
        expect(session).to respond_to(:has_text?)
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

    context 'when a page and `:url` supplied' do
      it 'uses the url' do
        session.visit(page, url: 'http://other.url/')
        expect(session.current_url).to eq('http://other.url/')
      end
    end

    context 'when `url` is supplied' do
      it 'visits that url' do
        expected_url = 'http://base.url/page'
        session.visit(expected_url)
        expect(browser.current_url).to eq(expected_url)
      end
    end
  end
end
