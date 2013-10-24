$LOAD_PATH.unshift("#{File.dirname(__FILE__)}")
require 'capybara'
require 'page_magic/site'
require 'page_magic/browser'
require 'page_magic/session'
require 'page_magic/ajax_support'
require 'page_magic/page_elements'
require 'page_magic/element_context'
require 'page_magic/page_element'
require 'page_magic/page_magic'
require 'page_magic/inline_page_section'
require 'page_magic/page_section'

module PageMagic
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