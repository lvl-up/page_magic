# frozen_string_literal: true

module PageMagic
  # Builder for creating ElementDefinitions
  class ElementDefinitionBuilder
    def initialize(definition_class:, selector:, query_class: PageMagic::Element::Query::SingleResult, element: nil)
      @definition_class = definition_class

      @query = if element
                 PageMagic::Element::Query::PrefetchedResult.new(element)
               else
                 query_class.new(*selector.args, options: selector.options)
               end
    end

    # Create new instance of the ElementDefinition modeled by this builder
    # @param [Object] browser_element capybara browser element corresponding to the element modelled by this builder
    # @return [Capybara::Node::Element]
    # @return [Array<Capybara::Node::Element>]
    def build(browser_element)
      query.execute(browser_element) do |result|
        definition_class.new(result)
      end
    end

    def ==(other)
      return false unless other.is_a?(ElementDefinitionBuilder)

      this = [query, definition_class]
      this == [other.send(:query), other.send(:definition_class)]
    end

    private

    attr_reader :query, :definition_class
  end
end
