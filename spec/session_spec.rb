require 'spec_helper'

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

  context 'move_to moves the session object to another page' do
    it 'can take a class' do
      page_magic_session = PageMagic::Session.new(double(:browser, current_url: '/another_page1'))
      page_magic_session.move_to(another_page_class)
      page_magic_session.current_page.should be_a(another_page_class)
    end

    it 'can take the name of the class as a string' do
      class ThePage
        include PageMagic
        url '/the_page'
      end

      page_magic_session = PageMagic::Session.new(double(:browser, current_url: '/the_page'))
      page_magic_session.move_to("ThePage")
      page_magic_session.current_page.should be_a(ThePage)
    end

    it 'should wait until the browser url has changed' do
      mock_browser = double(:browser, current_url: 'a')
      page_magic_session = PageMagic::Session.new(mock_browser)

      expect { page_magic_session.move_to(another_page_class) }.to raise_error(Wait::ResultInvalid)
    end
  end
end