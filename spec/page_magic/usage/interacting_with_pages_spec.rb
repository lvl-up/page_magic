describe 'interacting with pages' do
  include_context :webapp_fixture

  let :page do
    Class.new do
      include PageMagic
      link(:next_page, text: 'next page')
      url '/page1'
    end.new
  end

  before(:each) { page.visit }

  describe 'visit' do
    it 'goes to the class define url' do
      page.visit
      page.session.current_path.should == '/page1'
    end
  end

  describe 'session' do
    it 'gives access to the page magic object wrapping the user session' do
      page.session.raw_session.should == Capybara.current_session
    end
  end

  describe 'text_on_page?' do
    it 'returns true if the text is present' do
      page.text_on_page?('next page').should be_true
    end

    it 'returns false if the text is not present' do
      page.text_on_page?('not on page').should be_false
    end
  end

  describe 'title' do
    it 'returns the title' do
      page.title.should == 'page1'
    end
  end

  describe 'text' do
    it 'returns the text on the page' do
      page.text.should == 'next page'
    end
  end

  describe 'method_missing' do
    it 'gives access to the elements defined on your page classes' do
      page.next_page.tag_name.should == 'a'
    end
  end
end
