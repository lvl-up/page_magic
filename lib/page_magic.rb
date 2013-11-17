$LOAD_PATH.unshift("#{File.dirname(__FILE__)}")
require 'capybara'
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
      if browser.is_a?(Hash)
        Session.new(Capybara::Session.new(:rack_test, browser[:application]))
      else
        if browser
          application = options.delete(:application)

          Capybara.register_driver browser do |app|
            options[:browser] = browser
            case browser
              when :poltergeist
                require 'capybara/poltergeist'
                Capybara::Poltergeist::Driver.new(app)
              when :rack_test
                Capybara::RackTest::Driver.new(app, options)
              else
                require 'watir-webdriver'
                Capybara::Selenium::Driver.new(app, options)
            end

          end

          Session.new(Capybara::Session.new(browser, application))
        else
          Capybara.reset!
          Session.new(Capybara.current_session)
        end
      end

    end

    def included clazz
      clazz.extend PageElements
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