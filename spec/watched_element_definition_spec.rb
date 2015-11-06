module PageMagic
  describe Watcher do
    describe '#initialize' do
      context 'check has not been called yet'
      it 'it sets last to nil' do
        expect(subject.last).to be_nil
      end
    end
    describe '#check' do
      context 'block supplied to constructor' do
        subject do
          described_class.new(:text)
        end

        it 'assigns last to the value of attribute definined in the constructor' do
          browser_element = double(text: :hello)
          expect(subject.check(browser_element).last).to eq(:hello)
        end
      end

      context 'name and attribute supplied to constructor' do
        subject do
          described_class.new do
            :result
          end
        end
        it 'assigns last to the resut of the block' do
          expect(subject.check.last).to eq(:result)
        end
      end
    end
  end
end
