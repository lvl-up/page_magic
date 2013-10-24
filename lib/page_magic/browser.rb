module PageMagic
  module Browser
    class << self
      attr_reader :browser
      attr_accessor :session

      def use browser
        @browser = browser
      end
    end

    def page
      Browser.session ||= PageMagic.session(Browser.browser || :chrome)
    end
  end
end