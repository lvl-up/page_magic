module PageMagic
  module Browser
    class << self
      def session
        @session ||= PageMagic.session(default)
      end

      def default default=nil
        return (@default || :firefox) unless default
        @default = default
      end
    end

    def browser
      Browser.session
    end
  end
end