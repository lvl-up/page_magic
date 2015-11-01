module PageMagic
  describe InstanceMethods do
    include_context :webapp_fixture
    subject do
      clazz = Class.new do
        include PageMagic
        url '/page1'
        link(:next_page, text: 'next page')
      end
      clazz.new.tap(&:visit)
    end

    context '#respond_to?' do
      it 'checks self' do
        expect(subject.respond_to?(:visit)).to eq(true)
      end

      it 'checks the current page' do
        expect(subject.respond_to?(:next_page)).to eq(true)
      end
    end

    describe 'visit' do
      it 'goes to the class define url' do
        expect(subject.session.current_path).to eq('/page1')
      end
    end

    describe 'session' do
      it 'gives access to the page magic object wrapping the user session' do
        expect(subject.session.raw_session).to be(Capybara.current_session)
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

    describe 'text' do
      it 'returns the text on the page' do
        expect(subject.text).to eq('next page')
      end
    end

    describe 'method_missing' do
      it 'gives access to the elements defined on your page classes' do
        expect(subject.next_page.tag_name).to eq('a')
      end
    end
  end
end
