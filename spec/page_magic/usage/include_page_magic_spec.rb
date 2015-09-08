describe 'including PageMagic' do
  include Capybara::DSL

  context 'lets you define pages' do
    let :page_class do
      Class.new { include PageMagic }
    end

    it 'gives a method for defining the url' do
      page_class.url :url
      page_class.url.should == :url
    end

    it 'lets you define elements' do
      page_class.is_a?(PageMagic::Elements).should be_true
    end
  end
end
