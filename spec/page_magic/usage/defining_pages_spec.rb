describe 'The Elements of a Page' do

  describe 'instances' do

    include_context :webapp

    let(:my_page_class) do
      Class.new do
        include PageMagic
        url '/page1'
        link(:next, :text => "next page")
      end
    end

    let(:another_page_class) do
      Class.new do
        include PageMagic
        url '/another_page1'
      end
    end

    before :each do
      @page = my_page_class.new
    end


    describe 'browser integration' do
      it "should use capybara's default session if a one is not supplied" do
        Capybara.default_driver = :rack_test
        my_page_class.new.browser.mode.should == :rack_test
      end
    end


    it 'should copy fields on to element' do
      new_page = my_page_class.new
      @page.element_definitions[:next].call(@page).should_not equal(new_page.element_definitions[:next].call(new_page))
    end

    it 'gives access to the page text' do
      @page.visit.text.should == 'next page'
    end

    it 'should access a field' do
      @page.visit
      @page.click_next
      @page.text.should == 'page 2 content'
    end

    it 'are registered at class level' do
      PageMagic.instance_variable_set(:@pages, nil)

      page = Class.new { include PageMagic }
      PageMagic.pages.should == [page]
    end
  end

  describe 'inheritance' do
    let(:parent_page) do
      Class.new do
        include PageMagic
        link(:next, :text => "next page")
      end
    end

    let(:child_page) do
      Class.new(parent_page)
    end

    context 'children' do
      it 'should inherit elements defined on the parent class' do
        child_page.element_definitions.should include(:next)
      end

      it 'are added to PageMagic.pages list' do
        PageMagic.pages.should include(child_page)
      end

      it 'should pass on element definitions to their children' do
        grand_child_class = Class.new(child_page)
        grand_child_class.element_definitions.should include(:next)
      end
    end
  end
end