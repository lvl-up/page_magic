# frozen_string_literal: true

RSpec.describe PageMagic::ElementDefinitionBuilder do
  describe '#initialize' do
    context 'selector missing' do
      context 'object prefetched' do
        it 'does not raise an error' do
          execution = proc do
            described_class.new(definition_class: PageMagic::Element,
                                type: :element,
                                selector: nil,
                                element: Object.new)
          end
          expect(&execution).not_to raise_exception
        end
      end

      context 'selector defined on the definition_class' do
        it 'uses the selector on the class' do
          definition_class = Class.new(PageMagic::Element) do
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
          execution = proc { described_class.new(definition_class: PageMagic::Element, type: :element, selector: nil) }
          expect(&execution).to raise_exception PageMagic::UndefinedSelectorException,
                                                described_class::INVALID_SELECTOR_MSG
        end
      end

      context 'selector empty' do
        it 'raises an error' do
          execution = proc { described_class.new(definition_class: PageMagic::Element, type: :element, selector: {}) }
          expect(&execution).to raise_exception PageMagic::UndefinedSelectorException,
                                                described_class::INVALID_SELECTOR_MSG
        end
      end
    end

    context 'selector defined on definition_class' do
      it 'uses the supplied selector' do
        definition_class = Class.new(PageMagic::Element) do
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

  describe '#query' do
    it 'returns a capybara query' do
      options = { count: 1 }
      selector = { xpath: '//xpath' }
      builder = described_class.new(definition_class: PageMagic::Element,
                                    type: :text_field,
                                    selector: selector,
                                    options: options)

      expect(builder.query).to eq(PageMagic::Element::Query.new(:xpath, '//xpath', options: options))
    end
  end
end
