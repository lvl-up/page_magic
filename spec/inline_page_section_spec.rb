require 'spec_helper'

describe PageObject::InlinePageSection do
  it 'should have elements' do
    browser_element = double('browser')
    inline_section = Class.new do
      extend PageObject::InlinePageSection
      link(:hello)
    end

    inline_section.new(browser_element).elements(browser_element).should == [PageObject::PageElement.new(:hello,browser_element,:link)]
  end
end