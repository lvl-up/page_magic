$LOAD_PATH.unshift("#{File.dirname(__FILE__)}")
require 'capybara'
require 'page_magic/exceptions'
require 'page_magic/wait_methods'
require 'page_magic/watchers'
require 'page_magic/session'
require 'page_magic/session_methods'
require 'page_magic/elements'
require 'page_magic/element_context'
require 'page_magic/element'
require 'page_magic/class_methods'
require 'page_magic/instance_methods'
require 'page_magic/drivers'

# module PageMagic - PageMagic is an api for modelling pages in a website.
module PageMagic
  class << self
    # @return [Drivers] registered drivers
    def drivers
      @drivers ||= Drivers.new.tap(&:load)
    end

    def included(clazz)
      clazz.class_eval do
        include(InstanceMethods)
        extend(Elements, ClassMethods)
      end
    end

    # Visit this page based on the class level registered url
    # @param [Object] application rack application (optional)
    # @param [Symbol] browser name of browser
    # @param [String] url url to start the session on
    # @param [Hash] options browser driver specific options
    # @return [Session] configured sessoin
    def session(application: nil, browser: :rack_test, url:, options: {})
      driver = drivers.find(browser)
      fail UnspportedBrowserException unless driver

      Capybara.register_driver browser do |app|
        driver.build(app, browser: browser, options: options)
      end

      Session.new(Capybara::Session.new(browser, application), url)
    end
  end
end
