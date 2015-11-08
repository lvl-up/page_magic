module PageMagic
  # class WatchedElementDefinition - Contains the specification the for checking if an subject has changed
  class Watcher
    attr_reader :name, :attribute, :last, :block

    # @param [Symbol] name the of the subject being checked
    # @param [Symbol] method the method that should be called on the subject being checked
    # @example
    #  Watcher.new(:text)
    #  Watcher.new do
    #    session.url
    #  end
    def initialize(name, method = nil, &block)
      @name = name
      @attribute = method
      @block = block
    end

    # check current value of watched element. The result of the check is stored against {Watcher#last}
    # a block was specified then this will be executed.
    # @param [Object] subject - subject to run watcher against
    def check(subject = nil)
      @last = if block
                block.call
              else
                object = subject.send(name)
                attribute ? object.send(attribute) : object
              end
      self
    end

    # @param [Object] other candidate for equality check
    # @return [Boolen] true of the candiate is equal ot this one.
    def ==(other)
      other.is_a?(Watcher) &&
        name == other.name &&
        attribute == other.attribute &&
        block == other.block
    end
  end
end
