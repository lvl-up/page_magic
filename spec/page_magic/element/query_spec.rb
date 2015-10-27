module PageMagic
  class Element
    describe Query do
      describe '.find' do
        it 'finds the constant with the given name' do
          expect(Query.find(:button)).to be(described_class::BUTTON)
        end

        context 'constant not found' do
          it 'returns a default' do
            expect(Query.find(:billy)).to be(described_class::ELEMENT)
          end
        end
      end

      describe '#build' do
        let(:selector) { Selector.new }
        before do
          expect(Selector).to receive(:find).with(:css).and_return(selector)
        end
        let(:locator) { { css: '.css' } }

        it 'uses the locator to find the correct selector builder' do
          expect(subject.build(locator)).to eq(locator.values)
        end

        it 'adds options to the result' do
          expect(subject.build(locator, :options)).to eq(locator.values.concat([:options]))
        end

        context 'selector support element type' do
          subject do
            described_class.new(:field)
          end

          it 'passes element type through to the selector' do
            expect(selector).to receive(:build).with(:field, '.css').and_call_original
            subject.build(locator)
          end
        end
      end
    end

    class Query
      describe 'predefined queries' do
        it 'has a predefined query for each element type' do
          missing = PageMagic::Elements::TYPES.find_all do |type|
            !Query.constants.include?(type.upcase.to_sym)
          end
          expect(missing).to be_empty
        end

        describe 'queries for form fields' do
          it 'uses field as the element type' do
            expect(TEXT_FIELD.type).to eq(:field)
          end
          it 'uses the same query for all form field types' do
            expect(TEXT_FIELD).to eq(CHECKBOX).and eq(SELECT_LIST).and eq(RADIOS).and eq(TEXTAREA)
          end
        end

        it 'uses link as the element type for link' do
          expect(LINK.type).to eq(:link)
        end

        it 'uses the button element type for button' do
          expect(BUTTON.type).to eq(:button)
        end

        it 'does not use an element type for generic elements' do
          expect(ELEMENT.type).to eq(nil)
        end
      end
    end
  end
end
