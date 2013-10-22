require 'spec_helper'
require 'page_object'

describe 'member methods' do
  
  let(:page_object_class) do
    Class.new do
      extend PageObject::PageElements
    end
  end

  it 'should say you have fields when you do' do
    page_object_class.elements?.should == false
    page_object_class.link(:link, :text => "text")
    page_object_class.elements?.should == true
  end


  describe 'the element types that you can define' do
    PageObject::PageElements::ELEMENT_TYPES.each do |element_type|

      it "can have a #{element_type}" do
        friendly_name = "#{element_type}_name".to_sym
        page_object_class.send(element_type, friendly_name,{})
        page_object_class.elements(nil) == [PageObject::PageElement.new(friendly_name,element_type,{})]
      end
    end
  end


end