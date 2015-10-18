Bundler.require
$LOAD_PATH.unshift("#{File.dirname(__FILE__)}/lib")
if ENV['coverage']
  require 'simplecov'
  SimpleCov.start do
    add_filter '/spec/'
  end
end
require 'page_magic'
require 'capybara/rspec'
require 'helpers/capybara'

shared_context :files do
  require 'tmpdir'

  def scratch_dir
    @dir ||= Dir.mktmpdir
  end
end

shared_context :rack_application do
  let(:rack_application) do
    Class.new do
      def call(_env)
        [200, {}, ['hello world!!']]
      end
    end
  end
end

RSpec.configure do
  module PageMagic
    class Element
      class << self
        def default_before_hook
          @default_before_hook ||= proc {}
        end

        def default_after_hook
          @default_after_hook ||= proc {}
        end
      end
      alias_method :initialize_backup, :initialize

      def initialize(*args, &block)
        initialize_backup *args, &block
        # @before_hook = self.class.default_before_hook
        # @after_hook = self.class.default_after_hook
      end

      def ==(page_element)
        page_element.is_a?(Element) &&
            @type == page_element.type &&
            @name == page_element.name &&
            @selector == page_element.selector
        # @before_hook == page_element.before &&
        #     @after_hook == page_element.after
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


          <div id='form' class="form">
            <a id='form_link' href='/page2'>link in a form</a>
            <label>enter text
              <input id='field_id' name='field_name' class='input_class' type='text' value='filled in'/>
            </label>
            <input id='form_button' type='submit' value='a button'/>
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
