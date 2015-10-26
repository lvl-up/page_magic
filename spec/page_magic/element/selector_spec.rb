module PageMagic
  class Element
    describe Selector do

      describe '#build' do
        it 'puts the locator and element type in to the result' do
          expect(subject.build(:field, :locator)).to eq([:locator])
        end

        context 'supports_type flag set to true in constructor' do
          subject do
            described_class.new(supports_type: true)
          end
          it 'includes the element type in the result' do
            expect(subject.build(:field, :locator)).to eq([:field, :locator])
          end
        end

        context 'formatter supplied to constructor' do
          subject do
            described_class.new do |param|
              "formatted_#{param}".to_sym
            end
          end
          it 'uses the formatter' do
            expect(subject.build(:field, :locator)).to eq([:formatted_locator])
          end
        end

        context 'name supplied to constructor' do
          subject do
            described_class.new(:css)
          end

          it 'is added to the result' do
            expect(subject.build(:field, :locator)).to eq([:css, :locator])
          end
        end
      end
    end
  end
end