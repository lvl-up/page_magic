module Capybara
  class Query
    def ==(other)
      return unless other.is_a?(Query)
      this = [selector, locator, options, expression, find, negative]
      this == [other.selector, other.locator, other.options, other.expression, other.find, other.negative]
    end
  end
end
