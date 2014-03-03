Bundler.require
$LOAD_PATH.unshift("#{File.dirname(__FILE__)}/lib")
require 'page_magic'
require 'capybara/rspec'
require 'helpers/capybara'

RSpec.configure do

  include Capybara::DSL

  shared_context :webapp do
    require 'sinatra/base'

    rack_app = Class.new(Sinatra::Base) do
      get '/page1' do

        "<html><head><title>page1</title></head><body><a href='/page2'>next page</a></body></html>"
      end

      get '/page2' do
        'page 2 content'
      end

      get '/elements' do
        <<-ELEMENTS
          <a href='#'>a link</a>
          <input type='submit' value='a button'/>

          <div id='form' class="form">
            <a id='form_link' href='/page2'>a in a form</a>
          </form>
        ELEMENTS

      end
    end


    before :each do
      Capybara.app = rack_app
    end

    after do
      Capybara.reset!
    end
  end

end


