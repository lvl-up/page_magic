module PageMagic
  describe Session do
    let(:page) do
      Class.new do
        include PageMagic
      end
    end

    subject { described_class.new(browser) }

    let(:url) { 'http://url.com' }
    let(:browser) { double('browser', current_url: url, visit: nil, current_path: :current_path) }

    describe '#current_url' do
      it "returns the browser's current url" do
        expect(subject.current_url).to eq(browser.current_url)
      end
    end

    describe '#current_path' do
      it "returns the browser's current path" do
        expect(subject.current_path).to eq(browser.current_path)
      end
    end

    describe '#current_page' do
      let(:another_page_class) do
        Class.new do
          include PageMagic
          url '/another_page1'
        end
      end

      before do
        subject.define_page_mappings another_page_class.url => another_page_class
        subject.visit(page, url: url)
      end

      context 'page url has not changed' do
        it 'returns the original page' do
          allow(browser).to receive(:current_path).and_return(page.url)
          expect(subject.current_page).to be_an_instance_of(page)
        end
      end

      context 'page url has changed' do
        it 'returns the mapped page object' do
          allow(browser).to receive(:current_path).and_return(another_page_class.url)
          expect(subject.current_page).to be_an_instance_of(another_page_class)
        end
      end
    end

    describe '#find_mapped_page' do
      subject do
        described_class.new(nil).tap do |session|
          session.define_page_mappings '/page' => :mapped_page_using_string, /page\d/ => :mapped_page_using_regex
        end
      end

      context 'mapping is string' do
        it 'returns the page class' do
          expect(subject.find_mapped_page('/page')).to be(:mapped_page_using_string)
        end
      end
      context 'mapping is regex' do
        it 'returns the page class' do
          expect(subject.find_mapped_page('/page2')).to be(:mapped_page_using_regex)
        end
      end

      context 'mapping is not found' do
        it 'returns nil' do
          expect(subject.find_mapped_page('/fake_page')).to be(nil)
        end
      end
    end

    describe '#visit' do
      let(:session) do
        allow(browser).to receive(:visit)
        PageMagic::Session.new(browser, url)
      end

      it 'sets the current page' do
        session.define_page_mappings '/page' => page
        session.visit(page)
        expect(session.current_page).to be_a(page)
      end

      it 'uses the current url and the path in the page mappings' do
        session.define_page_mappings '/page' => page
        expect(browser).to receive(:visit).with("#{browser.current_url}/page")
        session.visit(page)
      end

      context 'no mappings found' do
        it 'raises an error' do
          expect { session.visit(page) }.to raise_exception InvalidURLException, described_class::URL_MISSING_MSG
        end
      end

      context 'mapping is a regular expression' do
        it 'raises an error' do
          session.define_page_mappings(/mapping/ => page)
          expect { session.visit(page) }.to raise_exception InvalidURLException, described_class::REGEXP_MAPPING_MSG
        end
      end

      context 'url supplied' do
        it 'visits that url' do
          expected_url = 'http://url.com/page'
          expect(browser).to receive(:visit).with(expected_url)
          session.visit(url: expected_url)
        end
      end
    end

    describe '#url' do

      let!(:base_url){'http://example.com'}
      let!(:path){'home'}
      let!(:expected_url){"#{base_url}/#{path}"}

      context 'base_url has a / on the end' do
        before do
          base_url << '/'
        end

        context 'path has / at the beginning' do
          it 'produces compound url' do
            expect(subject.url(base_url, path)).to eq(expected_url)
          end
        end

        context 'path does not have / at the beginning' do
          it 'produces compound url' do
            expect(subject.url(base_url, "/#{path}")).to eq(expected_url)
          end
        end

      end

      context 'current_url does not have a / on the end' do
        context 'path has / at the beginning' do
          it 'produces compound url' do
            expect(subject.url(base_url, "/#{path}")).to eq(expected_url)
          end
        end

        context 'path does not have / at the beginning' do
          it 'produces compound url' do
            expect(subject.url(base_url, path)).to eq(expected_url)
          end
        end

      end
    end

    context '#method_missing' do
      it 'should delegate to current page' do
        page.class_eval do
          def my_method
            :called
          end
        end

        session = PageMagic::Session.new(browser).visit(page, url: url)
        session.my_method.should be(:called)
      end
    end

    context '#respond_to?' do
      subject do
        PageMagic::Session.new(browser).tap do |s|
          s.current_page = page.new
        end
      end
      it 'checks self' do
        expect(subject.respond_to?(:current_url)).to eq(true)
      end

      it 'checks the current page' do
        page.class_eval do
          def my_method
          end
        end
        expect(subject.respond_to?(:my_method)).to eq(true)
      end
    end
  end
end
