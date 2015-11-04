module PageMagic
  # module ClassMethods - contains class level methods for PageObjects
  module ClassMethods
    DEFAULT_ON_LOAD = proc {}

    # getter setter for storing the page url
    # @param [String] url the url of the page
    def url(url = nil)
      @url = url if url
      @url
    end

    # sets block to run when page has loaded
    # if one has not been set on the page object class it will return a default block that does nothing
    def on_load(&block)
      return @on_load || DEFAULT_ON_LOAD unless block
      @on_load = block
    end
  end
end
