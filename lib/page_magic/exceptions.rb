module PageMagic
  class UnsupportedSelectorException < Exception

  end
  class UndefinedSelectorException < Exception
  end

  class MissingLocatorOrSelector < Exception
  end
end