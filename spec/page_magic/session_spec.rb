describe PageMagic::Session do

  let(:page) do
    Class.new do
      include PageMagic
      url '/page1'

      def my_method
        :called
      end
    end
  end

  let(:another_page_class) do
    Class.new do
      include PageMagic
      url '/another_page1'
    end
  end

  let(:browser) { double('browser', current_url: 'url') }

  describe '#current_page' do
    subject do
      PageMagic::Session.new(browser).tap do |session|
        session.define_page_mappings '/another_page1' => another_page_class
      end
    end
    context 'page url has not changed' do
      it 'returns the original page' do
        browser.should_receive(:visit).with(page.url)
        allow(browser).to receive(:current_path).and_return('/page1')
        subject.visit(page)
        expect(subject.current_page).to be_an_instance_of(page)
      end
    end

    context 'page url has changed' do
      it 'returns the mapped page object' do
        browser.should_receive(:visit).with(page.url)
        subject.visit(page)
        allow(browser).to receive(:current_path).and_return('/another_page1')
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

  it 'should visit the given url' do
    browser.should_receive(:visit).with(page.url)
    session = PageMagic::Session.new(browser).visit(page)
    session.current_page.should be_a(page)
  end

  it 'should return the current url' do
    session = PageMagic::Session.new(browser)
    session.current_url.should == 'url'
  end

  context 'method_missing' do
    it 'should delegate to current page' do
      browser.stub(:visit)
      session = PageMagic::Session.new(browser).visit(page)
      session.my_method.should be(:called)
    end
  end
end