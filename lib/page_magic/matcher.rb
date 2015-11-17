module PageMagic
  class Matcher

    attr_reader :path, :parameters, :fragment

    def initialize(path = nil, parameters: {}, fragment: nil)
      @path = path
      @parameters = parameters
      @fragment = fragment
    end

    def can_compute_uri?
      raise 'implement me'
    end

    def compute_uri
      path
    end

    def fuzzy?(component=nil)
      return component.is_a?(Regexp) if component
      ![path, parameters.values, fragment].flatten.compact.find{|o| fuzzy?(o) }.nil?
    end

    def match? string
      uri = URI(string)
      path_valid?(uri.path) && query_string_valid?(uri.query) && fragment_valid?(uri.fragment)
    end

    def hash
      [path, parameters, fragment].hash
    end

    def == other
      other.is_a?(Matcher) && self.path == other.path && self.parameters == other.parameters && self.fragment == other.fragment
    end

    alias eql? ==

    private
    def compatible?(string, comparitor)
      return true if comparitor.nil?
      if fuzzy?(comparitor)
        string =~ comparitor ? true : false
      else
        string == comparitor
      end
    end

    def path_valid? string
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
