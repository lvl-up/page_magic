describe PageMagic::Session do
  let(:page) do
    Class.new do
      include PageMagic
      url '/page1'
    end
  end

  subject { PageMagic::Session.new(browser) }

  let(:browser) { double('browser', current_url: 'url', visit: nil, current_path: :current_path) }

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
      subject.visit(page)
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
    context 'url supplied' do
      it 'uses this url instead of the one defined on the page class' do
        expect(browser).to receive(:visit).with(:custom_url)
        session = PageMagic::Session.new(browser).visit(page, url: :custom_url)
        expect(session.current_page).to be_a(page)
      end
    end

    it 'visits the url on defined on the page class' do
      browser.should_receive(:visit).with(page.url)
      session = PageMagic::Session.new(browser).visit(page)
      expect(session.current_page).to be_a(page)
    end
  end

  context '#method_missing' do
    it 'should delegate to current page' do
      page.class_eval do
        def my_method
          :called
        end
      end

      session = PageMagic::Session.new(browser).visit(page)
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
        def my_method; end
      end
      expect(subject.respond_to?(:my_method)).to eq(true)
    end
  end
end
