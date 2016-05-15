require 'active_support/core_ext/object/to_query'
module PageMagic
  # models mapping used to relate pages to uris
  class Matcher
    attr_reader :path, :parameters, :fragment

    # @raise [MatcherInvalidException] if at least one component is not specified
    def initialize(path = nil, parameters: nil, fragment: nil)
      raise MatcherInvalidException unless path || parameters || fragment
      @path = path
      @parameters = parameters
      @fragment = fragment
    end

    # @return [Boolean] true if no component contains a Regexp
    def can_compute_uri?
      !fuzzy?(fragment) && !fuzzy?(path) && !fuzzy?(parameters)
    end

    # @return [String] uri represented by this mapping
    def compute_uri
      path.to_s.tap do |uri|
        uri << "?#{parameters.to_query}" if parameters
        uri << "##{fragment}" if fragment
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
      path_valid?(uri.path) && query_string_valid?(uri.query) && fragment_valid?(uri.fragment)
    end

    # compare this matcher against another
    # @param [Matcher] other
    # @return [Fixnum] -1 = smaller, 0 = equal to, 1 = greater than
    def <=>(other)
      [:path, :parameters, :fragment].inject(0) do |result, component|
        result == 0 ? compare(send(component), other.send(component)) : result
      end
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

    def compare(this, other)
      return presence_comparison(this, other) unless this && other
      fuzzy_comparison(this, other)
    end

    def compatible?(string, comparitor)
      return true if comparitor.nil?
      if fuzzy?(comparitor)
        string =~ comparitor ? true : false
      else
        string == comparitor
      end
    end

    def fragment_valid?(string)
      compatible?(string, fragment)
    end

    def fuzzy?(component)
      return false unless component
      if component.is_a?(Hash)
        component.values.any? { |o| fuzzy?(o) }
      else
        component.is_a?(Regexp)
      end
    end

    def fuzzy_comparison(this, other)
      if fuzzy?(this)
        fuzzy?(other) ? 0 : 1
      else
        fuzzy?(other) ? -1 : 0
      end
    end

    def parameters_hash(string)
      CGI.parse(string.to_s.downcase).collect { |key, value| [key.downcase, value.first] }.to_h
    end

    def path_valid?(string)
      compatible?(string, path)
    end

    def presence_comparison(this, other)
      return 0 if this.nil? && other.nil?
      return 1 if this.nil? && other
      -1
    end

    def query_string_valid?(string)
      return true unless parameters
      !parameters.any? do |key, value|
        !compatible?(parameters_hash(string)[key.downcase.to_s], value)
      end
    end
  end
end
