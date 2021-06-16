# frozen_string_literal: true

module PageMagic
  module Elements
    CONFIG_STRUCT = Struct.new(:name,
                               :definition_class,
                               :type,
                               :selector,
                               :options,
                               :element,
                               :element_class,
                               keyword_init: true)

    # class Config - use to validate input to {PageMagic::Elements#elment}
    class Config < CONFIG_STRUCT
      INVALID_SELECTOR_MSG = 'Pass a locator/define one on the class'
      INVALID_ELEMENT_CLASS_MSG = 'Element class must be of type `PageMagic::Element`'
      TYPE_REQUIRED_MESSAGE = 'element type required'

      class << self
        # Create `Config` used to build instances `PageMagic::Element` see `Page::Elements#element` for details
        # @param [Args<Object>] args arguments passed to `Page::Elements#element`
        # @return [Config]
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

        private

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
          field?(type) ? :field : type
        end

        def field?(type)
          %i[ text_field checkbox select_list radio textarea field file_field fillable_field
              radio_button select].include?(type)
        end
      end

      # Options for the building of `PageMagic::Element` via `PageMagic::ElementDefinitionBuilder#new`
      # @return [Hash<Symbol,Object>]
      def element_options
        to_h.except(:element_class, :name, :type, :options).update(selector: selector)
      end

      # Selector built using supplied configuration
      # @return [PageMagic::Element::Selector::Model]
      def selector
        selector = self[:selector]
        Element::Selector.find(selector.keys.first).build(type, selector.values.first, options: options)
      end

      # Validate supplied configuration
      # @raise [PageMagic::InvalidConfigurationException]
      # @return [PageMagic::Elements::Config]
      def validate!
        raise PageMagic::InvalidConfigurationException, INVALID_SELECTOR_MSG unless element || valid_selector?
        raise PageMagic::InvalidConfigurationException, 'element type required' unless type
        raise PageMagic::InvalidConfigurationException, INVALID_ELEMENT_CLASS_MSG unless valid_element_class?

        self
      end

      private

      def valid_selector?
        selector = self[:selector]
        selector.is_a?(Hash) && !selector.empty?
      end

      def valid_element_class?
        element_class && (element_class == PageMagic::Element || element_class < PageMagic::Element)
      end
    end
  end
end
