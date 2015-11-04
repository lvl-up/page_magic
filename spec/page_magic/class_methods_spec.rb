module PageMagic
  describe ClassMethods do
    subject do
      Object.new.tap { |o| o.extend(described_class) }
    end
    describe '#url' do
      it 'get/sets a value' do
        subject.url(:url)
        expect(subject.url).to eq(:url)
      end
    end

    describe 'on_load' do
      context 'block not set' do
        it 'returns a default block' do
          expect(subject.on_load).to be(described_class::DEFAULT_ON_LOAD)
        end
      end

      context 'block set' do
        it 'returns that block' do
          expected_block = proc {}
          subject.on_load(&expected_block)
          expect(subject.on_load).to be(expected_block)
        end
      end
    end
  end
end
