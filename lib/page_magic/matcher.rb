# frozen_string_literal: true

require_relative '../active_support/core_ext/object/to_query'
require_relative 'matcher/comparator'
require_relative 'matcher/fuzzy'
require_relative 'matcher/literal'
require_relative 'matcher/map'
require_relative 'matcher/null'
module PageMagic
  # models mapping used to relate pages to uris
  class Matcher
    attr_reader :path, :parameters, :fragment

    # @param [Object] path String or Regular expression to match with
    # @param [Hash] parameters mapping of parameter name to literal or regex to match with
    # @param [Object] fragment String or Regular expression to match with
    # @raise [MatcherInvalidException] if at least one component is not specified
    def initialize(path = nil, parameters: {}, fragment: nil)
      raise MatcherInvalidException unless path || parameters || fragment

      @path = Comparator.for(path)
      @parameters = Comparator.for(parameters)
      @fragment = Comparator.for(fragment)
    end

    # @return [Boolean] true if no component contains a Regexp
    def can_compute_uri?
      !fragment.fuzzy? && !path.fuzzy? && !parameters.fuzzy?
    end

    # @return [String] uri represented by this mapping
    def compute_uri
      path.to_s.dup.tap do |uri|
        uri << "?#{parameters.comparator.to_query}" unless parameters.empty?
        uri << "##{fragment}" if fragment.present?
      end
    end

    # @return [Fixnum] hash for instance
    def hash
      [path, parameters, fragment].hash
    end

    # @param [String] uri
    # @return [Boolean] returns true if the uri is matched against this matcher
    def match?(uri)
      uri = URI(uri)
      path.match?(uri.path) && parameters.match?(parameters_hash(uri.query)) && fragment.match?(uri.fragment)
    end

    # compare this matcher against another
    # @param [Matcher] other
    # @return [Fixnum] -1 = smaller, 0 = equal to, 1 = greater than
    def <=>(other)
      path_comparison = path <=> other.path
      return path_comparison unless path_comparison == 0

      parameter_comparison = parameters <=> other.parameters
      return parameter_comparison unless parameter_comparison == 0

      fragment <=> other.fragment
    end

    # check equality
    # @param [Matcher] other
    # @return [Boolean]
    def ==(other)
      return false unless other.is_a?(Matcher)

      path == other.path && parameters == other.parameters && fragment == other.fragment
    end

    alias eql? ==

    private

    def parameters_hash(string)
      CGI.parse(string.to_s.downcase).collect { |key, value| [key.downcase, value.first] }.to_h
    end
  end
end
