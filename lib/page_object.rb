$LOAD_PATH.unshift("#{File.dirname(__FILE__)}")
require 'capybara'
require 'page_object/site'
require 'page_object/session'
require 'page_object/ajax_support'
require 'page_object/page_elements'
require 'page_object/element_context'
require 'page_object/page_element'
require 'page_object/page_object'
require 'page_object/inline_page_section'
require 'page_object/page_section'

module PageObject
  class << self
    def included clazz
      clazz.extend PageElements

      def clazz.url url=nil
        @url = url if url
        @url
      end
    end
  end
end