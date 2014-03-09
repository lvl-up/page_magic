Bundler.require
$LOAD_PATH.unshift("#{File.dirname(__FILE__)}/lib")
if ENV['coverage']
  require 'simplecov'
  SimpleCov.start do

    add_filter "/spec/"
  end
end
require 'page_magic'
require 'capybara/rspec'
require 'helpers/capybara'



RSpec.configure do

  module PageMagic
    class Element
      class << self
        def default_before_hook
          @default_before_hook ||= Proc.new {}
        end

        def default_after_hook
          @default_after_hook ||= Proc.new {}
        end
      end
      alias_method :initialize_backup, :initialize
      def initialize *args, &block
        initialize_backup *args, &block
        @before_hook, @after_hook = self.class.default_before_hook, self.class.default_after_hook
      end

      def == page_element
        page_element.is_a?(Element) &&
            @type == page_element.type &&
            @name == page_element.name &&
            @selector == page_element.selector
            @before_hook == page_element.before &&
            @after_hook == page_element.after
      end

    end
  end

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


