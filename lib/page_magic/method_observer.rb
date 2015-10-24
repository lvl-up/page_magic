module PageMagic
  module MethodObserver
    def singleton_method_added(arg)
      @singleton_methods_added = true unless arg == :singleton_method_added
    end

    def singleton_methods_added?
      @singleton_methods_added == true
    end
  end
end
