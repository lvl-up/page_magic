require 'spec_helper'

describe PageMagic::InlinePageSection do
  it 'should have elements' do
    browser_element = double('browser')
    inline_section = Class.new do
      extend PageMagic::InlinePageSection
      link(:hello)
    end

    inline_section.new(browser_element).elements(browser_element).should == [PageMagic::PageElement.new(:hello, browser_element, :link)]
  end
end