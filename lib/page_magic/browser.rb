module PageMagic
  module Browser
    class << self
      def use browser
        @browser = browser
      end

      def browser
        @browser || :chrome
      end

      def session
        @session ||= PageMagic.session(browser)
      end
    end

    def browser
      Browser.session
    end
  end
end