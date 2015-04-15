describe PageMagic::Session do

  let(:page) do
    Class.new do
      include PageMagic
      url :url

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
        session.define_transitions '/another_page1' => another_page_class
      end
    end
    context 'page url has not changed' do
      it 'returns the original page' do
        browser.should_receive(:visit).with(page.url)
        subject.visit(page)
        expect(subject.current_page).to be_an_instance_of(page)
      end
    end

    context 'page url has changed' do

      it 'returns the mapped page object' do
        browser.should_receive(:visit).with(page.url)
        subject.visit(page)
        allow(browser).to receive(:current_url).and_return('http://example.com/another_page1')
        expect(subject.current_page).to be_an_instance_of(another_page_class)
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