# frozen_string_literal: true

RSpec.describe PageMagic::InstanceMethods do
  let(:page_class) do
    Class.new.tap do |klass|
      klass.include(described_class)
    end
  end

  it_behaves_like 'session accessor'
  it_behaves_like 'element watcher'
  it_behaves_like 'waiter'
  it_behaves_like 'element locator'

  describe 'execute_on_load' do
    let(:page_class) do
      Class.new.tap do |klass|
        klass.extend(PageMagic::ClassMethods)
        klass.include(described_class)
        klass.include RSpec::Matchers
      end
    end

    it 'runs the on_load_hook in the context of self' do
      instance = page_class.new
      page_class.on_load do
        expect(self).to be(instance)
      end

      instance.execute_on_load
    end

    it 'returns self' do
      instance = page_class.new
      expect(instance.execute_on_load).to be(instance)
    end
  end

  describe '#respond_to?' do
    it 'checks element definitions' do
      instance = page_class.new
      allow(instance).to receive(:contains_element?).and_return(true)
      expect(instance).to respond_to(:next_page)
    end
  end

  describe '#text' do
    it 'returns the text on the page' do
      session = PageMagic::Session.new(instance_double(Capybara::Session, text: 'text'))
      instance = page_class.new(session)
      expect(instance.text).to eq('text')
    end
  end

  describe '#text_on_page?' do
    it 'returns true if the text is present' do
      session = PageMagic::Session.new(instance_double(Capybara::Session, text: 'text'))
      instance = page_class.new(session)

      expect(instance.text_on_page?('text')).to eq(true)
    end

    it 'returns false if the text is not present' do
      session = PageMagic::Session.new(instance_double(Capybara::Session, text: 'text'))
      instance = page_class.new(session)

      expect(instance.text_on_page?('not on page')).to eq(false)
    end
  end

  describe 'title' do
    it 'returns the title' do
      session = PageMagic::Session.new(instance_double(Capybara::Session, title: 'page1'))
      instance = page_class.new(session)

      expect(instance.title).to eq('page1')
    end
  end

  describe 'method_missing' do
    let(:spy_element_context) { spy }

    it 'gives access to element definitions' do
      instance = page_class.new
      allow(PageMagic::ElementContext).to receive(:new).with(instance).and_return(spy_element_context)
      instance.next_page(:arg1, :arg2)
      expect(spy_element_context).to have_received(:next_page).with(:arg1, :arg2)
    end
  end
end
