# frozen_string_literal: true

require 'ostruct'
RSpec.describe PageMagic::SessionMethods do
  subject(:session_methods) do
    OpenStruct.new(session: session).tap do |o|
      o.extend(described_class)
    end
  end

  let(:session) do
    rack_app = instance_double(Proc, call: [200, {}, ['<html><head><title>page1</title></head></html>']])
    PageMagic.session(application: rack_app, url: '/page1')
  end

  describe '#execute_script' do
    it 'returns the output of Session#execute_script' do
      allow(session.raw_session).to receive(:execute_script).with(:script).and_return(:result)
      expect(session_methods.execute_script(:script)).to eq(:result)
    end
  end

  describe '#page' do
    it 'returns the current page of the session' do
      expect(session_methods.page).to eq(session.current_page)
    end
  end

  describe '#path' do
    it 'returns the path of the session' do
      expect(session_methods.path).to eq(session.current_path)
    end
  end

  describe '#url' do
    it 'returns the url of the session' do
      expect(session_methods.url).to eq(session.current_url)
    end
  end
end
