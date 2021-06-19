# frozen_string_literal: true

RSpec.describe PageMagic::Watcher do
  describe '#initialize' do
    context 'when `check` has not been called yet' do
      it 'sets `observed_value` to nil' do
        instance = described_class.new(:custom_watcher)
        expect(instance.observed_value).to be_nil
      end
    end
  end

  describe '#check' do
    context 'when a method supplied to constructor' do
      it 'assigns last to be the result of calling the method' do
        instance = described_class.new(:object_id)
        instance.check(self)
        expect(instance.observed_value).to eq(object_id)
      end
    end

    context 'when name and attribute supplied to constructor' do
      it 'assigns `observed_value` to the value of the attribute' do
        instance = described_class.new(:my_button, :text)
        browser_element = instance_double(Capybara::Node::Element, text: :hello)
        page_element = Struct.new(:my_button).new(browser_element)
        expect(instance.check(page_element).observed_value).to eq(:hello)
      end
    end

    context 'when a block is supplied' do
      subject(:instance) do
        described_class.new(:custom_watcher) do
          method_call
          :result
        end
      end

      it 'is executed in the context the caller' do
        context = Struct.new(:method_call).new(nil)
        allow(context).to receive(:method_call)
        instance.check(context)
        expect(context).to have_received(:method_call)
      end

      it 'assigns last to the result of the block' do
        context = Struct.new(:method_call).new(nil)
        expect(instance.check(context).observed_value).to eq(:result)
      end
    end
  end
end
