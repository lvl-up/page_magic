# frozen_string_literal: true

RSpec.describe PageMagic::Watcher do
  describe '#initialize' do
    context 'when `check` has not been called yet' do
      it 'sets `observed_value` to nil' do
        instance = described_class.new(:custom_watcher, context: self)
        expect(instance.observed_value).to be_nil
      end
    end
  end

  describe '#check' do
    it 'assigns last to be the result of calling the block passed to the constructor' do
      instance = described_class.new(:object_id, context: self) do
        object_id
      end
      instance.check
      expect(instance.observed_value).to eq(object_id)
    end
  end
end
