# frozen_string_literal: true

module PageMagic
  # class WatchedElementDefinition - Contains the specification the for checking if an subject has changed
  class Watcher
    attr_reader :name, :context, :observed_value, :block

    # @param [Symbol] name the of the subject being checked
    # @example
    #  Watcher.new(:url) do
    #    session.url
    #  end
    def initialize(name, context:, &block)
      @name = name
      @context = context
      @block = block
    end

    # check current value of watched element. The result of the check can be accessed
    # by calling {PageMagic::Watcher#last}
    # if a block was specified to the constructor then this will be executed.
    # @return [PageMagic::Watcher]
    def check
      @observed_value = context.instance_eval(&block)
      self
    end

    # @param [Object] other candidate for equality check
    # @return [Boolen] true of the candiate is equal ot this one.
    def ==(other)
      other.is_a?(Watcher) &&
        name == other.name &&
        block == other.block
    end
  end
end
