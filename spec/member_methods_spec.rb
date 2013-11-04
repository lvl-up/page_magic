require 'spec_helper'
require 'page_magic'

describe 'member methods' do
  
  let(:page_object_class) do
    Class.new do
      extend PageMagic::PageElements
    end
  end

  it 'should say you have fields when you do' do
    page_object_class.elements?.should == false
    page_object_class.link(:link, :text => "text")
    page_object_class.elements?.should == true
  end


  describe 'the element types that you can define' do
    PageMagic::PageElements::ELEMENT_TYPES.each do |element_type|

      it "can have a #{element_type}" do
        parent_page_element = double('parent_page_object', browser_element: double('browser_element'))
        friendly_name = "#{element_type}_name".to_sym

        page_object_class.send(element_type, friendly_name,{})


        expected_element = PageMagic::PageElement.new(friendly_name,parent_page_element, element_type, {})
        page_object_class.element_definitions[friendly_name].call(parent_page_element) == expected_element
      end
    end
  end


end