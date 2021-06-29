# frozen_string_literal: true

require_relative 'utils/url'
require_relative 'matcher'

module PageMagic
  # class Transitions - used for registering the page classes that should be used against particular paths
  class Transitions < Hash
    REGEXP_MAPPING_MSG = 'URL could not be derived because mapping contains Regexps'

    # Create a new transitions object.
    # @param [Hash{String,PageMagic::Matcher => PageMagic}] transitions a map of paths to pages
    # @example
    #  Transitions.new('/path1' => Page1, Matcher.new('/another_*') => AnotherPageClass )
    def initialize(transitions)
      super
      transitions.each do |key, value|
        key = key.is_a?(Matcher) ? key : Matcher.new(key)
        self[key] = value
      end
    end

    # get the url to be used when visiting the path mapped against the given page
    # @param [PageMagic] page - the page class to get the mapped path from
    # @param [String] base_url - the base url of the site to be joined to the mapped path
    # @return String
    # @raise InvalidURLException - Raised if it is not possible to generate the url for the mapped page
    #  i.e. if the mapping is a regular expression.
    def url_for(page, base_url:)
      mapping = key(page)
      raise InvalidURLException, REGEXP_MAPPING_MSG unless mapping.can_compute_uri?

      PageMagic::Utils::URL.concat(base_url, mapping.compute_uri)
    end

    # get the page class mapped to the given url
    # @param [String] url - the url to search against
    # @return [PageMagic]
    def mapped_page(url)
      matches(url).first
    end

    private

    def matches(url)
      keys.find_all { |matcher| matcher.match?(url) }.sort.collect { |match| self[match] }
    end
  end
end
