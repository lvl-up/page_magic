module PageMagic
  class Element
    describe Query do
      describe '#build' do
        let(:selector){Selector.new}
        before do
          expect(Selector).to receive(:find).with(:css).and_return(selector)
        end
        let(:locator){{css: '.css'}}

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
  end
end