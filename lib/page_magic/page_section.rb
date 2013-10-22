module PageMagic
  module PageSection
    class UndefinedSelectorException < Exception

    end

    class << self
      def extended clazz
        clazz.extend(PageElements)
        clazz.class_eval do
          attr_reader :name, :selector
          class << self
            def selector selector=nil
              return @selector unless selector
              @selector = selector
            end
          end
          def initialize browser_element, name=nil, selector=self.class.selector
            @selector, @browser_element = selector, browser_element

            @selector = selector ? selector : self.class.selector

            raise UndefinedSelectorException, "Pass a selector to the constructor/define one the class" unless @selector
            if name
              @name = name
            else
              @name = underscore(self.class.name).to_sym
            end

          end

          # TODO test this
          def locate *args
            method, selector = @selector.to_a.flatten
            case method
              when :id
                @browser_element.find("##{selector}")
              when :css
                @browser_element.find(:css, selector)
              else
                raise UnsupportedSelectorException
            end

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
