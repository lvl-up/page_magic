# frozen_string_literal: true

module PageMagic
  module Utils
    # module String - contains methods for manipulating strings
    module URL
      class << self
        # build a url from a base and path.
        # @example
        #  concat('http://base.url/', '/path') # => "http://base.url/path"
        # @return [String]
        def concat(base_url, path)
          path = path.sub(%r{^/}, '')
          base_url = base_url.sub(%r{/$}, '')
          "#{base_url}/#{path}"
        end
      end
    end
  end
end
