# frozen_string_literal: true

RSpec.describe PageMagic::Element::Locators do
  subject { element_clazz.new }

  let(:element_clazz) do
    Class.new do
      extend(PageMagic::Elements)
      include(PageMagic::Element::Locators)
    end
  end

  describe '#element_by_name' do
    it 'returns the required element' do
      selector = { id: 'child' }
      element_clazz.element :child1, selector
      element_clazz.element :child2, id: 'child 2'

      child_1_builder = PageMagic::ElementDefinitionBuilder.new(
        definition_class: PageMagic::Element,
        type: :element,
        selector: selector
      )

      expect(subject.element_by_name(:child1)).to eq(child_1_builder)
    end

    context 'element not found' do
      it 'raises an error' do
        expected_message = (described_class::ELEMENT_NOT_DEFINED_MSG % :child)
        expect{subject.element_by_name(:child)}.to raise_exception PageMagic::ElementMissingException, expected_message
      end
    end
  end
end
