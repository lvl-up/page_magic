module PageMagic
  class Element
    describe Locators do
      subject do
        Object.new.tap do |o|
          o.extend(Elements)
          o.extend(described_class)
        end
      end
      describe '#element_by_name' do
        it 'returns the required element' do
          expected_element = Element.new(subject, type: :element, selector: { id: 'child' })
          subject.element :child1, expected_element.selector
          subject.element :child2, id: 'child 2'

          expect(subject.element_by_name(:child1)).to eq(expected_element)
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
