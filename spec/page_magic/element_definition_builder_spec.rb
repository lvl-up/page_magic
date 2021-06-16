# frozen_string_literal: true

RSpec.describe PageMagic::ElementDefinitionBuilder do
  describe '#build' do
    it 'returns an instance of `definition_class`' do
      options = { count: 1 }
      builder = described_class.new(
        definition_class: PageMagic::Element,
        selector: PageMagic::Element::Selector.find(:xpath).build(:text_field, '//xpath', options: options)
      )

      allow_any_instance_of(PageMagic::Element::Query::SingleResult).to receive(:execute) do |_query, element, &block|
        block.call(element)
      end

      expect(builder.build(:capybara_object)).to have_attributes(browser_element: :capybara_object)
    end
  end
end
