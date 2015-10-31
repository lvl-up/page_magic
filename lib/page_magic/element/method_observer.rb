module PageMagic
  class Element
    # module MethodObserver - adds methods to check if a methods have been added.
    module MethodObserver
      # Hook called by ruby when a singleton method is added.
      #
      # @param [String, #arg] name of the method added
      def singleton_method_added(arg)
        @singleton_methods_added = true unless arg == :singleton_method_added
      end

      # returns true if a singleton method has been added
      #
      # @return [Boolean]
      def singleton_methods_added?
        @singleton_methods_added == true
      end
    end
  end
end
