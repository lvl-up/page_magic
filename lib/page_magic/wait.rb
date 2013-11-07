module PageMagic
  module WaitUntil
    def wait
      @wait ||= Wait.new
    end
  end
end