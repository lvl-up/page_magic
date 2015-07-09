$LOAD_PATH.unshift("#{File.dirname(__FILE__)}")
require 'capybara'
require 'page_magic/exceptions'
require 'page_magic/session'
require 'page_magic/elements'
require 'page_magic/element_context'
require 'page_magic/element'
require 'page_magic/page_magic'
require 'page_magic/drivers'

module PageMagic
  class << self

    def drivers
      @drivers ||= Drivers.new.tap do |drivers|
        drivers.load
      end
    end

    def session(application: nil, browser: :rack_test, options: {})
      Capybara.register_driver browser do |app|
        drivers.find(browser).build(app, browser: browser, options: options)
      end

      Session.new(Capybara::Session.new(browser, application))
    end

    def included clazz
      clazz.extend Elements
      pages << clazz if clazz.is_a? Class

      class << clazz
        def url url=nil
          @url = url if url
          @url
        end

        def inherited clazz
          clazz.element_definitions.merge!(element_definitions)
          PageMagic.pages << clazz
        end
      end

    end

    def pages
      @pages||=[]
    end
  end
end