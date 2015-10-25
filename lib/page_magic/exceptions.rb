module PageMagic
  class UnsupportedSelectorException < Exception
  end
  class UndefinedSelectorException < Exception
  end

  class MissingLocatorOrSelector < Exception
  end

  class InvalidElementNameException < Exception
  end

  class InvalidMethodNameException < Exception
  end
end
