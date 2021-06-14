class Model
  attr_reader :args, :options
  def initialize(args, options={})
    @args = args
    @options = options
  end

  def ==(other)
    other.args == self.args && other.options == self.options
  end
end
