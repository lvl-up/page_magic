require 'spec_helper'

describe PageMagic::Browser do
  let(:app) { Object.new }

  before do
    PageMagic::Browser.session = nil
    app.extend PageMagic::Browser
  end

  describe 'page' do
    it 'should return the existing session' do
      session = double(:session)
      PageMagic::Browser.session = session

      app.page.should == session
    end

    it 'should create a session if not already set' do
      new_session = double(:new_session)

      PageMagic.should_receive(:session).with(:chrome).and_return new_session
      app.page.should == new_session
    end

    it 'should use custom browser' do
      PageMagic::Browser.use :firefox

      PageMagic.should_receive(:session).with(:firefox)
      app.page
    end
  end
end