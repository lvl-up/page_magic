# frozen_string_literal: true

RSpec.describe PageMagic::SessionMethods do
  subject do
    OpenStruct.new(session: session).tap do |o|
      o.extend(described_class)
    end
  end

  include_context 'webapp fixture'
  let(:session) { PageMagic.session(application: rack_app, url: '/page1') }

  describe '#execute_script' do
    it 'returns the output of Session#execute_script' do
      expect(session.raw_session).to receive(:execute_script).with(:script).and_return(:result)
      expect(subject.execute_script(:script)).to eq(:result)
    end
  end

  describe '#page' do
    it 'returns the current page of the session' do
      expect(subject.page).to eq(session.current_page)
    end
  end

  describe '#path' do
    it 'returns the path of the session' do
      expect(subject.path).to eq(session.current_path)
    end
  end

  describe '#url' do
    it 'returns the url of the session' do
      expect(subject.url).to eq(session.current_url)
    end
  end
end
