module PageMagic
  describe ClassMethods do
    subject do
      Class.new.tap do |clazz|
        clazz.extend(described_class)
        clazz.include(InstanceMethods)
      end
    end

    describe '#load' do
      let(:page_title) { 'page title' }
      let(:page_source) do
        <<-HTML
          <html>
            <head><title>#{page_title}</title></head>
          </html>
        HTML
      end

      it 'returns an instance using that source' do
        expect(subject.load(page_source).title).to eq(page_title)
      end
    end

    describe 'on_load' do
      context 'block not set' do
        it 'returns a default block' do
          expect(subject.on_load).to be(described_class::DEFAULT_ON_LOAD)
        end
      end

      context 'block set' do
        it 'returns that block' do
          expected_block = proc {}
          subject.on_load(&expected_block)
          expect(subject.on_load).to be(expected_block)
        end
      end
    end

    describe '#url' do
      it 'get/sets a value' do
        subject.url(:url)
        expect(subject.url).to eq(:url)
      end
    end

    describe '#visit' do
      include_context :webapp_fixture
      it 'passes all options to create an active session on the registered url' do
        subject.url '/page1'
        expect(PageMagic).to receive(:session).with(application: rack_app,
                                                    options: {},
                                                    browser: :rack_test,
                                                    url: subject.url).and_call_original

        session = subject.visit(application: rack_app, options: {}, browser: :rack_test)

        expect(session.title).to eq('page1')
      end
    end
  end
end
