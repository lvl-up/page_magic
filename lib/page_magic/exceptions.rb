module PageMagic
  class ElementMissingException < Exception
  end

  class InvalidElementNameException < Exception
  end

  class InvalidMethodNameException < Exception
  end

  class InvalidURLException < Exception
  end

  class MatcherInvalidException < Exception
  end

  class TimeoutException < Exception
  end

  class UnspportedBrowserException < Exception
  end

  class UnsupportedCriteriaException < Exception
  end

  class UnsupportedSelectorException < Exception
  end

  class UndefinedSelectorException < Exception
  end
end
