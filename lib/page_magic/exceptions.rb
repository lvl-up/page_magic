module PageMagic
  class UnsupportedSelectorException < Exception
  end

  class UndefinedSelectorException < Exception
  end

  class InvalidElementNameException < Exception
  end

  class InvalidMethodNameException < Exception
  end

  class UnsupportedCriteriaException < Exception
  end

  class ElementMissingException < Exception
  end

  class InvalidURLException < Exception
  end

  class UnspportedBrowserException < Exception
  end
end
