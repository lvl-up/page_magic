module PageMagic
  # class UnsupportedSelectorException - raised when a user has used a selector not supported by page magic
  class UnsupportedSelectorException < Exception
  end

  # class UndefinedSelectorException - raised when a PageElement has been defined without a selector
  class UndefinedSelectorException < Exception
  end

  # class InvalidElementNameException - rasied when name used is already by another element or method.
  class InvalidElementNameException < Exception
  end

  # class InvalidMethodNameException - raised when a page element name with the same name already exists
  class InvalidMethodNameException < Exception
  end

  # class UnsupportedCriteriaException - raised when unsupported selection criteria are used.
  class UnsupportedCriteriaException < Exception
  end

  # class ElementMissingException - raised when a element with given name can not be found.
  class ElementMissingException < Exception
  end

  # class InvalidURLException - raised if url is poorly formated or not supplied
  class InvalidURLException < Exception
  end

  class UnspportedBrowserException < Exception
  end
end
