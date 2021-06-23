# frozen_string_literal: true

require 'ostruct'
RSpec.describe PageMagic::Watchers do
  include described_class
  let(:element) { OpenStruct.new(text: :current_value) }

  describe '#changed?' do
    context 'when the watched element has changed' do
      it 'returns true' do
        watch(:element_watcher, context: element, method: :text)
        element.text = :new_value
        expect(changed?(:element_watcher)).to eq(true)
      end
    end

    context 'when the watched element has not changed' do
      it 'returns false' do
        watch(:element_watcher, context: element, method: :text)
        expect(changed?(:element_watcher)).to eq(false)
      end
    end
  end

  describe '#watch' do
    it 'stores the initial value of the watched element' do
      watch(:element_watcher, context: element, method: :text)
      expect(watcher(:element_watcher).observed_value).to eq(:current_value)
    end

    context 'when a method name is supplied' do
      it 'stores the watch instruction' do
        watch(:object_id)
        watcher = watcher(:object_id)
        expect(watcher.check.observed_value).to eq(object_id)
      end
    end

    context 'when a watcher name and a method are supplied' do
      it 'stores the watch instruction' do
        watch(:my_watcher, method: :object_id)
        watcher = watcher(:my_watcher)
        expect(watcher.check.observed_value).to eq(object_id)
      end
    end

    context 'when a block is supplied' do
      it 'stores the watch instruction' do
        block = proc { :value }
        watch(:my_watcher, &block)
        watcher = watcher(:my_watcher)
        expect(watcher.check.observed_value).to eq(:value)
      end
    end

    context 'when a watcher with the same name is added' do
      it 'replaces the watcher' do
        original_watcher = watch(:object_id)
        expect(watcher(:object_id)).not_to be(original_watcher)
      end
    end

    context 'when a watcher defined on a method that does not exist' do
      it 'raises an error' do
        expected_message = described_class::ELEMENT_MISSING_MSG % :text
        expect do
          watch(:missing, method: :text)
        end.to raise_exception(PageMagic::ElementMissingException, expected_message)
      end
    end
  end

  describe '#watcher' do
    it 'returns the watcher with the given name' do
      watch(:my_watcher, method: :object_id)
      watcher = watcher(:my_watcher)
      expect(watcher.check.observed_value).to eq(object_id)
    end
  end
end
