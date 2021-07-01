RSpec.describe PageMagic::Comparator::Literal do
  describe 'match?' do
    context 'when parameter is the same' do
      it 'returns true' do
        expect(described_class.new('/')).to be_match('/')
      end
    end

    context 'when it parameter is not the same' do
      it 'returns false' do
        expect(described_class.new('/')).not_to be_match('foo')
      end
    end
  end

  describe '#fuzzy?' do
    it 'returns false' do
      expect(described_class.new('value')).not_to be_fuzzy
    end
  end

  describe '#<=>' do
    context 'when other is `Null`' do
      it 'is greater' do
        expect(described_class.new('/') <=> PageMagic::Comparator::Null.new).to be 1
      end
    end

    context 'when other is `Fuzzy`' do
      it 'is greater' do
        expect(described_class.new('/') <=> PageMagic::Comparator::Fuzzy.new(//)).to be 1
      end
    end

    context 'when other is `Literal`' do
      it 'is equal' do
        expect(described_class.new('/') <=> described_class.new('/')).to be 0
      end
    end
  end
end
