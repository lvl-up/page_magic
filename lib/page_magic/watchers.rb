require 'page_magic/watcher'

module PageMagic
  # module Watchers - contains methods for adding watchers and checking them
  module Watchers
    # @return [Hash] registered watchers
    def watchers
      @watchers ||= {}
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
      watched_element = if block
                          Watcher.new(&block)
                        else
                          Watcher.new(method)
                        end
      watchers[name] = watched_element.check(send(name))
    end

    # @param [Symbol] name - the name of the watcher
    # @return [Boolean] true if a change is detected
    def changed?(name)
      watched_element = watchers[name]
      watched_element.last != watched_element.check(send(name)).last
    end
  end
end
