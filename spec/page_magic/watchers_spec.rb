# frozen_string_literal: true

module PageMagic
  describe Watchers do
    let(:element) { OpenStruct.new(text: :current_value) }

    subject do
      Object.new.tap do |o|
        o.extend(described_class)
        allow(o).to receive(:my_watcher).and_return(element)
      end
    end

    describe '#changed?' do
      before do
        subject.watch(:my_watcher, :text)
      end

      context 'watched element has changed' do
        it 'returns true' do
          element.text = :new_value
          expect(subject.changed?(:my_watcher)).to eq(true)
        end
      end

      context 'watched element has not changed' do
        it 'returns false' do
          expect(subject.changed?(:my_watcher)).to eq(false)
        end
      end
    end

    describe '#watch' do
      it 'stores the initial value of the watched element' do
        subject.watch(:my_watcher, :text)
        expect(subject.watcher(:my_watcher).last).to eq(:current_value)
      end

      context 'element name/ method name supplied' do
        it 'stores the watch instruction' do
          subject.watch(:object_id)
          expect(subject.watcher(:object_id)).to eq(Watcher.new(:object_id))
        end
      end

      context 'element name and attribute supplied' do
        it 'stores the watch instruction' do
          subject.watch(:my_watcher, :text)
          expect(subject.watcher(:my_watcher)).to eq(Watcher.new(:my_watcher, :text))
        end
      end

      context 'block supplied' do
        it 'stores the watch instruction' do
          block = proc {}
          subject.watch(:my_watcher, &block)
          expect(subject.watcher(:my_watcher)).to eq(Watcher.new(:my_watcher, &block))
        end
      end

      context 'watcher with the same name added' do
        it 'replaces the watcher' do
          subject.watch(:object_id)
          original_watcher = subject.watchers.first
          subject.watch(:object_id)
          expect(subject.watchers.size).to eq(1)
          expect(subject.watchers.first).to_not be(original_watcher)
        end
      end

      context 'watcher defined on element that does not exist' do
        it 'raises an error' do
          expected_message = described_class::ELEMENT_MISSING_MSG % :missing
          expect { subject.watch(:missing, :text) }.to raise_exception(ElementMissingException, expected_message)
        end
      end
    end

    describe '#watcher' do
      it 'returns the watcher with the given name' do
        subject.watch(:my_watcher, :text)
        expect(subject.watcher(:my_watcher)).to eq(Watcher.new(:my_watcher, :text))
      end
    end
  end
end
