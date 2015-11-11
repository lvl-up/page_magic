module PageMagic
  describe ElementDefinitionBuilder do
    describe '#initialize' do
      context 'selector missing' do
        context 'object prefetched' do
          it 'does not raise an error' do
            execution = proc do
              described_class.new(definition_class: Element,
                                  type: :element,
                                  selector: nil,
                                  element: Object.new)
            end
            expect(&execution).to_not raise_exception
          end
        end

        context 'selector nil' do
          it 'raises an error' do
            execution = proc { described_class.new(definition_class: Element, type: :element, selector: nil) }
            expect(&execution).to raise_exception UndefinedSelectorException, described_class::INVALID_SELECTOR_MSG
          end
        end

        context 'selector empty' do
          it 'raises an error' do
            execution = proc { described_class.new(definition_class: Element, type: :element, selector: {}) }
            expect(&execution).to raise_exception UndefinedSelectorException, described_class::INVALID_SELECTOR_MSG
          end
        end
      end
    end
  end
end
