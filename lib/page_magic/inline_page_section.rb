module PageMagic
  module InlinePageSection
    class UndefinedSelectorException < Exception

    end

    class << self
      def extended clazz
        clazz.extend(PageElements)
        clazz.class_eval do
          attr_reader :name

          def initialize browser_element
            @browser_element = browser_element
          end

          #TODO - consolidate this
          def method_missing method, *args
            ElementContext.new(self, @browser_element, self, *args).send(method, args.first)
          end

          private

          def underscore string
            string.gsub(/::/, '/').
                gsub(/([A-Z]+)([A-Z][a-z])/,'\1_\2').
                gsub(/([a-z\d])([A-Z])/,'\1_\2').
                tr("-", "_").
                downcase
          end


        end
      end
    end
  end
end
