module PageMagic
  module Browser

    class << self
      attr_writer :default
      def session
        @session ||= PageMagic.session(default)
      end

      def default
        @default || :firefox
      end
    end

    def browser
      Browser.session
    end
  end
end