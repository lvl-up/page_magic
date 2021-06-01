# frozen_string_literal: true

RSpec.shared_context 'webapp fixture' do |path: '/'|
  require 'sinatra/base'

  let(:rack_app) do
    Class.new(Sinatra::Base) do
      get '/page1' do
        "<html><head><title>page1</title></head><body><a href='/page2'>next page</a></body></html>"
      end

      get '/page2' do
        'page 2 content'
      end

      get '/elements' do
        <<-ELEMENTS
          <a href='#'>a link</a>


          <div id='form' class="form">
            <a id='form_link' href='/page2'>link in a form</a>
            <label>enter text
              <input id='field_id' name='field_name' class='input_class' type='text' value='filled in'/>
            </label>
            <button id='form_button' type='submit' value='a button'/>
          </form>

        ELEMENTS
      end
    end
  end

  let(:capybara_session) { Capybara::Session.new(:rack_test, rack_app).tap { |s| s.visit(path) } }

  around do |example|
    Capybara.app = rack_app
    example.call
    Capybara.reset!
  end
end
