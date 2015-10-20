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
  class UnspportedBrowserException < Exception; end

  module ClassMethods
    def url(url = nil)
      @url = url if url
      @url
    end

    def inherited(clazz)
      clazz.element_definitions.merge!(element_definitions)
    end
  end

  class << self
    def drivers
      @drivers ||= Drivers.new.tap(&:load)
    end

    def session(application: nil, browser: :rack_test, options: {})
      driver = drivers.find(browser)
      fail UnspportedBrowserException unless driver

      Capybara.register_driver browser do |app|
        driver.build(app, browser: browser, options: options)
      end

      Session.new(Capybara::Session.new(browser, application))
    end

    def included(clazz)
      clazz.extend(Elements, ClassMethods)
    end
  end
end
