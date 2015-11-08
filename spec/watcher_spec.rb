module PageMagic
  describe Watcher do
    describe '#initialize' do
      context 'check has not been called yet' do
        subject do
          described_class.new(:custom_watcher)
        end
        it 'it sets last to nil' do
          expect(subject.last).to be_nil
        end
      end
    end

    describe '#check' do
      context 'method supplied to constructor' do
        subject do
          described_class.new(:object_id)
        end

        it 'assigns last to be the result of calling the method' do
          subject.check(self)
          expect(subject.last).to eq(object_id)
        end
      end
      context 'name and attribute supplied to constructor' do
        subject do
          described_class.new(:my_button, :text)
        end

        it 'assigns last to the value of attribute definined in the constructor' do
          browser_element = double(text: :hello)
          page_element = double(my_button: browser_element)
          expect(subject.check(page_element).last).to eq(:hello)
        end
      end

      context 'block supplied to constructor' do
        subject do
          described_class.new(:custom_watcher) do
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
