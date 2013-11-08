$LOAD_PATH.unshift("#{File.dirname(__FILE__)}")
require 'capybara'
require 'wait'
require 'page_magic/wait'
require 'page_magic/browser'
require 'page_magic/session'
require 'page_magic/ajax_support'
require 'page_magic/page_elements'
require 'page_magic/element_context'
require 'page_magic/page_element'
require 'page_magic/page_magic'
require 'page_magic/page_section'

module PageMagic
  class << self
    def session browser=nil, options = {}
      if browser
        Capybara.register_driver browser do |app|
          options[:browser] = browser
          Capybara::Selenium::Driver.new(app, options)
        end
        Session.new(Capybara::Session.new(browser, nil))
      else
        Capybara.reset!
        Session.new(Capybara.current_session)
      end
    end

    def included clazz
      clazz.extend ClassMethods, PageElements
      pages << clazz if clazz.is_a? Class

      def clazz.url url=nil
        @url = url if url
        @url
      end
    end

    def pages
      @pages||=[]
    end
  end

  module ClassMethods
    def included clazz
      clazz.instance_eval { include PageMagic }
      clazz.element_definitions.merge!(element_definitions)
    end

    def method_missing method_name, *args
      raise "You can only instantiate child pages" if method_name == :new
      super
    end
  end
end