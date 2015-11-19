require 'active_support/core_ext/object/to_query'
module PageMagic
  class Matcher
    attr_reader :path, :parameters, :fragment

    def initialize(path = nil, parameters: nil, fragment: nil)
      @path = path
      @parameters = parameters
      @fragment = fragment
    end

    def can_compute_uri?
      !fragment.is_a?(Regexp) && !path.is_a?(Regexp) && !parameters.values.find { |v| v.is_a?(Regexp) }
    end

    def compute_uri
      "#{path}".tap do |uri|
        uri << "?#{parameters.to_query}" unless parameters.empty?
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

    def score
      score = 0
      score += fuzzy?(path) ? 1 : 2 if path
      parameters.values.each do |value|
        score += fuzzy?(value) ? 1 : 2
      end
      score += fuzzy?(fragment) ? 1 : 2 if fragment
      score
    end

    def <=> other
      result = if path
                 if other.path
                   if fuzzy?(path)
                     fuzzy?(other.path) ? 0 : 1
                   else
                     fuzzy?(other.path) ? -1 : 0
                   end
                 else
                   -1
                 end
               elsif other.path
                 1
               else
                 0
               end
      return result unless result == 0
      if parameters
        if !other.parameters
          -1
        else
          if fuzzy?(parameters)
            fuzzy?(other.parameters) ? 0 : 1
          else
            fuzzy?(other.parameters) ? -1 : 0
          end
        end
      elsif other.parameters
        1
      else
        0
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
      if component
        if component.is_a?(Hash)
          return !component.keys.find{|o|fuzzy?(o)}.nil?
        else
          return component.is_a?(Regexp) if component
        end
      end
      ![path, parameters, fragment].compact.find { |o| fuzzy?(o) }.nil?
    end

    def path_valid?(string)
      compatible?(string, path)
    end

    def fragment_valid?(string)
      compatible?(string, fragment)
    end

    def query_string_valid?(string)
      actual_parameters = CGI.parse(string.to_s.downcase).collect { |key, value| [key.downcase, value.first] }.to_h
      parameters.find do |key, value|
        !compatible?(actual_parameters[key.downcase.to_s], value)
      end.nil?
    end
  end
end
