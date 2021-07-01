RSpec.describe PageMagic::Comparator::Null do
  describe '#fuzzy?' do
    context 'when one value is fuzzy' do
      it 'returns true' do
        expect(described_class.new).not_to be_fuzzy
      end
    end
  end

  describe 'match?' do
    it 'returns false' do
      expect(described_class.new).to be_match(true)
    end
  end

  describe '#<=>' do
    context 'when other is `Null`' do
      it 'is equal' do
        expect(described_class.new <=> described_class.new).to be 0
      end
    end

    context 'when other is `Fuzzy`' do
      it 'is greater' do
        expect(described_class.new <=> PageMagic::Comparator::Fuzzy.new(//)).to be 1
      end
    end

    context 'when other is `Literal`' do
      it 'is greater' do
        expect(described_class.new <=> PageMagic::Comparator::Literal.new('/')).to be 1
      end
    end
  end
end
