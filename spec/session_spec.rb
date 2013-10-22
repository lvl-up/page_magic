require 'spec_helper'

describe PageObject::Session do

  let(:page) do
    Class.new do
      include PageObject
      url :url
    end
  end

  it 'should visit the given url' do
    browser = double('browser')
    browser.should_receive(:visit).with(page.url)
    visited_page = PageObject::Session.new(browser).visit(page)
    visited_page.is_a?(page).should be_true
  end
end