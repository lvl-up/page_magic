# frozen_string_literal: true

RSpec.describe PageMagic::InstanceMethods do
  subject do
    page_class.visit(application: rack_app)
  end

  include_context 'webapp fixture'

  let(:page_class) do
    Class.new do
      include PageMagic
      url '/page1'
      link(:next_page, text: 'next page')
    end
  end

  it_behaves_like 'session accessor'
  it_behaves_like 'element watcher'
  it_behaves_like 'waiter'
  it_behaves_like 'element locator'

  describe 'execute_on_load' do
    it 'runs the on_load_hook in the context of self' do
      instance = subject.current_page
      page_class.on_load do
        extend RSpec::Matchers
        expect(self).to be(instance)
      end

      subject.execute_on_load
    end

    it 'returns self' do
      expect(subject.execute_on_load).to be(subject.current_page)
    end
  end

  describe '#respond_to?' do
    it 'checks self' do
      expect(subject.respond_to?(:visit)).to eq(true)
    end

    it 'checks element definitions' do
      expect(subject.respond_to?(:next_page)).to eq(true)
    end
  end

  describe 'session' do
    it 'gives access to the page magic object wrapping the user session' do
      expect(subject.session.raw_session).to be_a(Capybara::Session)
    end
  end

  describe 'text' do
    it 'returns the text on the page' do
      expect(subject.text).to eq('next page')
    end
  end

  describe 'text_on_page?' do
    it 'returns true if the text is present' do
      expect(subject.text_on_page?('next page')).to eq(true)
    end

    it 'returns false if the text is not present' do
      expect(subject.text_on_page?('not on page')).to eq(false)
    end
  end

  describe 'title' do
    it 'returns the title' do
      expect(subject.title).to eq('page1')
    end
  end

  describe '#visit' do
    it 'goes to the class define url' do
      expect(subject.session.current_path).to eq('/page1')
    end
  end

  describe 'method_missing' do
    it 'gives access to the elements defined on your page classes' do
      expect(subject.next_page.tag_name).to eq('a')
    end
  end
end
