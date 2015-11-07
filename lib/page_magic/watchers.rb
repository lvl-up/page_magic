require 'page_magic/watcher'

module PageMagic
  # module Watchers - contains methods for adding watchers and checking them
  module Watchers
    # @param [Symbol] name - the name of the watcher
    # @return [Boolean] true if a change is detected
    def changed?(name)
      watched_element = watchers[name]
      watched_element.last != watched_element.check(send(name)).last
    end

    # register a new watcher
    # @param [Object] name of the watcher/element
    # @param [Symbol] method - the method on the watched element to check
    # @yieldreturn [Object] the value that should be checked
    # @example
    #  watch(:price, :text)
    # @example
    #  watch(:something) do
    #   # more complicated code to get value
    # end
    def watch(name, method = nil, &block)
      watched_element = block ? Watcher.new(&block) : Watcher.new(method)
      watchers[name] = watched_element.check(send(name))
    end

    # @return [Hash] registered watchers
    def watchers
      @watchers ||= {}
    end
  end
end
