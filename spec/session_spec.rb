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

  let(:browser) { double('browser') }

  it 'should visit the given url' do
    browser.should_receive(:visit).with(page.url)
    session = PageMagic::Session.new(browser).visit(page)
    session.current_page.should be_a(page)
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
      page_magic_session = PageMagic::Session.new(double(:browser))
      page_magic_session.move_to(another_page_class)
      page_magic_session.current_page.should be_a(another_page_class)
    end

    it 'can take the name of the class as a string' do
      page_magic_session = PageMagic::Session.new(double(:browser))
      String.should_receive(:new).and_return "String"
      page_magic_session.move_to("String")
      page_magic_session.current_page.should be_a(String)
    end
  end
end