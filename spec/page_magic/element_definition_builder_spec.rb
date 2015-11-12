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

        context 'selector defined on the definition_class' do
          it 'uses the selector on the class' do
            definition_class = Class.new(Element) do
              selector css: 'selector'
            end

            builder = described_class.new(definition_class: definition_class,
                                          type: :element,
                                          selector: nil)

            expect(builder.selector).to eq(css: 'selector')
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

      context 'selector defined on definition_class' do
        it 'uses the supplied selector' do
          definition_class = Class.new(Element) do
            selector css: 'selector'
          end

          expected_selector = { id: 'id' }
          builder = described_class.new(definition_class: definition_class,
                                        type: :element,
                                        selector: expected_selector)

          expect(builder.selector).to eq(expected_selector)
        end
      end
    end

    describe 'build_query' do
      it 'returns a capybara query' do
        options = { count: 1 }
        selector = { xpath: '//xpath' }
        builder = described_class.new(definition_class: Element,
                                      type: :text_field,
                                      selector: selector,
                                      element: Object.new,
                                      options: options)

        expect(builder.build_query).to eq([:xpath, '//xpath', options])
      end
    end
  end
end
