module PageMagic
  # class WatchedElementDefinition - Contains the specification the for checking if an element has changed
  class Watcher
    attr_reader :name, :attribute, :last, :block

    # @param [Symbol] method - the method that should be called on the element being checked
    # @example
    #  Watcher.new(:text)
    #  Watcher.new do
    #    session.url
    #  end
    def initialize(method = nil, &block)
      @attribute = method
      @block = block
    end

    # check current value of watched element. The result of the check is stored against {Watcher#last}
    # a block was specified then this will be executed.
    # @param [Object] element - element to run watcher against
    def check(element = nil)
      @last = if block
                block.call
              else
                element.send(attribute)
              end
      self
    end

    def ==(other)
      other.is_a?(Watcher) &&
        name == other.name &&
        attribute == other.attribute &&
        block == other.block
    end
  end
end
