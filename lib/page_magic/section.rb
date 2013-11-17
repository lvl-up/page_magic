module PageMagic
  module Section

    module Location
      def locate_in browser_element, selector
        method, selector = selector.to_a.flatten
        case method
                             when :id
                               browser_element.find("##{selector}")
                             when :css
                               browser_element.find(:css, selector)
                             else
                               raise UnsupportedSelectorException
                           end
      end
    end
    class UndefinedSelectorException < Exception

    end

    class << self
      def extended clazz
        clazz.extend(Elements)
        clazz.class_eval do
          attr_reader :name, :selector
          class << self
            def selector selector=nil
              return @selector unless selector

              if @parent_browser_element
                @browser_element = locate_in @parent_browser_element, selector
              end

              @selector = selector
            end

            attr_accessor :parent_browser_element, :browser_element
          end

          include Location
          extend Location

          def initialize parent_page_element, name=nil, selector=self.class.selector

            @selector = selector
            @parent_page_element = parent_page_element

            @selector = selector ? selector : self.class.selector

            raise UndefinedSelectorException, "Pass a selector to the constructor/define one the class" unless @selector
            @browser_element = locate_in(@parent_page_element.browser_element, @selector)
            if name
              @name = name
            else
              @name = underscore(self.class.name).to_sym
            end

          end


          def session
            @parent_page_element.session
          end

          # TODO test this
          def locate *args
            @browser_element
          end

          #TODO - consolidate this
          def method_missing method, *args
            begin
              ElementContext.new(self, @browser_element, self, *args).send(method, args.first)
            rescue ElementMissingException
              begin
                @browser_element.send(method, *args)
              rescue
                super
              end

            end
          end

          private

          def underscore string
            string.gsub(/::/, '/').
                gsub(/([A-Z]+)([A-Z][a-z])/, '\1_\2').
                gsub(/([a-z\d])([A-Z])/, '\1_\2').
                tr("-", "_").
                downcase
          end


        end
      end
    end


  end
end
