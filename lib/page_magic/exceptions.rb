# frozen_string_literal: true

module PageMagic
  class ElementMissingException < RuntimeError
  end

  class AmbiguousQueryException < RuntimeError
  end

  class InvalidElementNameException < RuntimeError
  end

  class InvalidMethodNameException < RuntimeError
  end

  class InvalidURLException < RuntimeError
  end

  class MatcherInvalidException < RuntimeError
  end

  class TimeoutException < RuntimeError
  end

  class UnsupportedBrowserException < RuntimeError
  end

  class UnsupportedCriteriaException < RuntimeError
  end

  class UnsupportedSelectorException < RuntimeError
  end

  class UndefinedSelectorException < RuntimeError
  end

  class NotSupportedException < RuntimeError
  end
end
