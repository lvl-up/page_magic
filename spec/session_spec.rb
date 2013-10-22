require 'spec_helper'

describe PageObject::Session do

  let(:page) do
    Class.new do
      include PageObject
      url :url

      def my_method
        :called
      end
    end
  end

  let(:browser) { double('browser') }

  it 'should visit the given url' do
    browser.should_receive(:visit).with(page.url)
    session = PageObject::Session.new(browser).visit(page)
    session.current_page.should be_a(page)
  end

  context 'method_missing' do
    it 'should delegate to current page' do
      browser.stub(:visit)
      session = PageObject::Session.new(browser).visit(page)
      session.my_method.should be(:called)
    end
  end
end