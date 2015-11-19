require 'active_support/core_ext/object/to_query'
module PageMagic
  # models mapping used to relate pages to uris
  class Matcher
    attr_reader :path, :parameters, :fragment

    def initialize(path = nil, parameters: nil, fragment: nil)
      @path = path
      @parameters = parameters
      @fragment = fragment
    end

    def can_compute_uri?
      !fragment.is_a?(Regexp) && !path.is_a?(Regexp) && !fuzzy?(parameters)
    end

    def compute_uri
      "#{path}".tap do |uri|
        uri << "?#{parameters.to_query}" if parameters
        uri << "##{fragment}" if fragment
      end
    end

    def hash
      [path, parameters, fragment].hash
    end

    def match?(string)
      uri = URI(string)
      path_valid?(uri.path) && query_string_valid?(uri.query) && fragment_valid?(uri.fragment)
    end

    def <=>(other)
      result = compare(path, other.path)
      return result unless result == 0
      result = compare(parameters, other.parameters)
      return result unless result == 0
      compare(fragment, other.fragment)
    end

    def compare(this, other)
      return presence_comparison(this, other) unless this && other
      fuzzy_comparison(this, other)
    end

    def presence_comparison(this, other)
      return 0 if this.nil? && other.nil?
      return 1 if this.nil? && other
      -1
    end

    def fuzzy_comparison(this, other)
      if fuzzy?(this)
        fuzzy?(other) ? 0 : 1
      else
        fuzzy?(other) ? -1 : 0
      end
    end

    def ==(other)
      other.is_a?(Matcher) && path == other.path && parameters == other.parameters && fragment == other.fragment
    end

    alias_method :eql?, :==

    private

    def compatible?(string, comparitor)
      return true if comparitor.nil?
      if fuzzy?(comparitor)
        string =~ comparitor ? true : false
      else
        string == comparitor
      end
    end

    def fuzzy?(component = nil)
      return false unless component
      if component.is_a?(Hash)
        return !component.values.find { |o| fuzzy?(o) }.nil?
      else
        return component.is_a?(Regexp)
      end
    end

    def path_valid?(string)
      compatible?(string, path)
    end

    def fragment_valid?(string)
      compatible?(string, fragment)
    end

    def query_string_valid?(string)
      return true unless parameters
      actual_parameters = parameters_hash(string)
      parameters.find do |key, value|
        !compatible?(actual_parameters[key.downcase.to_s], value)
      end.nil?
    end

    def parameters_hash(string)
      CGI.parse(string.to_s.downcase).collect { |key, value| [key.downcase, value.first] }.to_h
    end
  end
end
