# frozen_string_literal: true

require_relative 'watcher'

module PageMagic
  # module Watchers - contains methods for adding watchers and checking them
  module Watchers
    ELEMENT_MISSING_MSG = 'Unable to defined watcher: Element or method with the name %s can not be found'

    # @param [Symbol] name - the name of the watcher
    # @return [Boolean] true if a change is detected
    def changed?(name)
      watched_element = watcher(name)
      watched_element.observed_value != watched_element.check.observed_value
    end

    # register a new watcher
    # @overload watch(:price, context: object, method: :text)
    #  @param [Symbol] name of the watcher/element
    #  @param [Object] context the object that is being watched - defaults to self
    #  @param [Symbol] method - the method on the watched element to check
    # @overload watch(:text)
    #  @param [Symbol] method - the method on the watched element to check
    # @overload watch(:text, &blk)
    #  @param [Symbol] name of the watcher/element
    #  @yieldreturn [Object] the value that should be checked
    #  @example
    #   watch(:something) do
    #   # more complicated code to get value
    #   end
    def watch(name, context: self, method: nil, &blk)
      watcher = blk ? Watcher.new(name, context: context, &blk) : watch_method(name, context: context, method: method)
      watchers.delete_if { |w| w.name == name }
      watchers << watcher.check
    end

    # retrieve a watcher given its name
    # @param [Symbol] name the name of the watcher
    # @return [Watcher] watcher with the given name
    def watcher(name)
      watchers.find { |watcher| watcher.name == name }
    end

    # @return [Array] registered watchers
    def watchers
      @watchers ||= []
    end

    private

    def watch_method(name, context:, method:)
      subject = method || name
      raise ElementMissingException, (ELEMENT_MISSING_MSG % subject) unless context.respond_to?(subject)

      Watcher.new(name, context: context) do
        public_send(subject)
      end
    end
  end
end
