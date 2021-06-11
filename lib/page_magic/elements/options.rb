module PageMagic
  class InvalidConfigurationException < StandardError

  end
  module Elements
    Options = Struct.new(:name, :definition_class, :type, :selector, :options, :element, :element_class, keyword_init: true) do

      class << self

        def build(args, type)
          element_class = remove_argument(args, Class) || Element

          new(
            name: compute_name(args, element_class),
            type: type_for(type),
            selector: compute_selector(args, element_class),
            options: compute_argument(args, Hash),
            element: args.delete_at(0),
            element_class: element_class
          )
        end

        def compute_name(args, element_class)
          name = remove_argument(args, Symbol)
          name || element_class.name.demodulize.underscore.to_sym unless element_class.is_a?(Element)
        end

        def compute_selector(args, element_class)
          selector = remove_argument(args, Hash)
          selector || element_class.selector if element_class.respond_to?(:selector)
        end

        def compute_argument(args, clazz)
          remove_argument(args, clazz) || clazz.new
        end

        def remove_argument(args, clazz)
          argument = args.find { |arg| arg.is_a?(clazz) }
          args.delete(argument)
        end

        def type_for(type)
          is_field?(type) ? :field : type
        end

        def is_field?(type)
          %i{
            text_field
            checkbox
            select_list
            radio
            textarea
            field
            file_field
            fillable_field
            radio_button
            select
          }.include?(type)
        end
      end

      def element_options
        to_h.except(:element_class, :name, :type, :options).update(selector: selector)
      end

      def selector
        selector = self[:selector]
        PageMagic::Element::Selector.find(selector.keys.first).build(type, selector.values.first, options: options)
      end

      def validate!
        # INVALID_SELECTOR_MSG = 'Pass a locator/define one on the class'
        raise PageMagic::InvalidConfigurationException unless element || valid_selector
        raise PageMagic::InvalidConfigurationException unless type
        raise PageMagic::InvalidConfigurationException unless element_class && (element_class == PageMagic::Element || element_class < PageMagic::Element)
      end

      private
      def valid_selector
        selector = self[:selector]
        selector.is_a?(Hash) && !selector.empty?
      end

    end
  end
end

