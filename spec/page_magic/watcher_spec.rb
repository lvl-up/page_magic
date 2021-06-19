# frozen_string_literal: true

RSpec.describe PageMagic::Watcher do
  describe '#initialize' do
    context 'check has not been called yet' do
      subject do
        described_class.new(:custom_watcher)
      end

      it 'sets last to nil' do
        expect(subject.observed_value).to be_nil
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
        expect(subject.observed_value).to eq(object_id)
      end
    end

    context 'name and attribute supplied to constructor' do
      subject do
        described_class.new(:my_button, :text)
      end

      it 'assigns last to the value of attribute definined in the constructor' do
        browser_element = double(text: :hello)
        page_element = double(my_button: browser_element)
        expect(subject.check(page_element).observed_value).to eq(:hello)
      end
    end

    context 'block supplied to constructor' do
      def method_on_self(value = nil)
        return @value unless value

        @value = value
      end

      subject do
        described_class.new(:custom_watcher) do
          method_on_self(:called)
          :result
        end
      end

      it 'is called on self' do
        subject.check(self)
        expect(method_on_self).to be(:called)
      end

      it 'assigns last to the resut of the block' do
        expect(subject.check(self).observed_value).to eq(:result)
      end
    end
  end
end
