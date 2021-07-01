# frozen_string_literal: true

require 'capybara'
require_relative 'page_magic/exceptions'
require_relative 'page_magic/wait_methods'
require_relative 'page_magic/watchers'
require_relative 'page_magic/session'
require_relative 'page_magic/session_methods'
require_relative 'page_magic/elements'
require_relative 'page_magic/element_context'
require_relative 'page_magic/element'
require_relative 'page_magic/class_methods'
require_relative 'page_magic/instance_methods'
require_relative 'page_magic/drivers'

# module PageMagic - PageMagic is an api for modelling pages in a website.
module PageMagic
  extend SingleForwardable

  # @!method matcher
  # define match critera for loading a page object class
  # @see Mapping#initialize
  # @return [Mapping]
  def_delegator Mapping, :new, :matcher

  class << self
    # @return [Drivers] registered drivers
    def drivers
      @drivers ||= Drivers.new.tap(&:load)
    end

    def included(clazz)
      clazz.class_eval do
        include(InstanceMethods)
        extend ClassMethods
        extend Elements
      end
    end

    # Create a more complex mapping to identify when a page should be loaded
    # @example
    #   PageMagic.mapping '/', parameters: {project: 'page_magic'}, fragment: 'display'
    # @see Matchers#initialize
    def mapping(path = nil, parameters: nil, fragment: nil)
      Mapping.new(path, parameters: parameters, fragment: fragment)
    end

    # Visit this page based on the class level registered url
    # @param [Object] application rack application (optional)
    # @param [Symbol] browser name of browser
    # @param [String] url url to start the session on
    # @param [Hash] options browser driver specific options
    # @return [Session] configured session
    def session(url: nil, application: nil, browser: :rack_test, options: {})
      driver = drivers.find(browser)
      raise UnsupportedBrowserException unless driver

      Capybara.register_driver browser do |app|
        driver.build(app, browser: browser, options: options)
      end

      Session.new(Capybara::Session.new(browser, application), url)
    end
  end
end
