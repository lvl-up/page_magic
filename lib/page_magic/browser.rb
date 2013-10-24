module PageMagic
  module Browser
    class << self
      attr_reader :browser

      def use browser
        @browser = browser
      end
    end

    def page
      @session ||= PageMagic::Site.visit(browser: Browser.browser ? Browser.browser : :chrome)
    end
  end
end