# frozen_string_literal: true

module PageMagic
  class Element
    # class NotFound - Used to represent elements which are missing. All method calls other than
    # to those that check visibility thrown a {PageMagic::ElementMissingException} exception
    class NotFound
      # @private [Capybara::ElementNotFound] exception
      def initialize(exception)
        @exception = exception
      end

      # @return [Boolean] - always false
      def visible?
        false
      end

      # @return [Boolean] - always false
      def present?
        false
      end

      # @raise [PageMagic::ElementMissingException]
      def method_missing(*_args)
        raise ElementMissingException, exception.message
      end

      # @return [Boolean] - always true
      def respond_to_missing?(_args)
        true
      end

      private

      attr_reader :exception
    end
  end
end
