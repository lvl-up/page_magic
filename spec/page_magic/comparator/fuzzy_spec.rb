RSpec.describe PageMagic::Comparator::Fuzzy do
  describe '#fuzzy?' do
    context 'when one value is fuzzy' do
      it 'returns true' do
        map = described_class.new(//)
        expect(map).to be_fuzzy
      end
    end
  end

  describe 'match?' do
    context 'when comparator contains the parameter' do
      it 'returns true' do
        expect(described_class.new(/f*o/)).to be_match('foo')
      end
    end

    context 'when comparator does not contains the parameter' do
      it 'returns false' do
        expect(described_class.new(/f*o/)).not_to be_match('bar')
      end
    end
  end

  describe '#<=>' do
    context 'when other is `Null`' do
      it 'is lesser' do
        expect(described_class.new(//) <=> PageMagic::Comparator::Null.new).to be(-1)
      end
    end

    context 'when other is `Fuzzy`' do
      it 'is equal' do
        expect(described_class.new(//) <=> described_class.new(//)).to be 0
      end
    end

    context 'when other is `Literal`' do
      it 'is greater' do
        expect(described_class.new(//) <=> PageMagic::Comparator::Literal.new('/')).to be 1
      end
    end
  end
end
