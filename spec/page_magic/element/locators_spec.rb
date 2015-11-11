module PageMagic
  class Element
    describe Locators do
      subject(:element_clazz) do
        Class.new do
          extend(Elements)
          include(Locators)
        end
      end
      subject { element_clazz.new }

      describe '#element_by_name' do
        it 'returns the required element' do
          expected_element = Element.new(type: :element, selector: { id: 'child' })
          element_clazz.element :child1, expected_element.selector
          element_clazz.element :child2, id: 'child 2'

          expect(subject.element_by_name(:child1).options).to eq(type: :element, selector: { id: 'child' })
        end

        context 'element not found' do
          it 'raises an error' do
            expected_message = (described_class::ELEMENT_MISSING_MSG % :child)
            command = proc { subject.element_by_name(:child) }
            expect(&command).to raise_exception ElementMissingException, expected_message
          end
        end
      end
    end
  end
end
