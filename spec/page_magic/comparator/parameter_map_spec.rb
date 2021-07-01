RSpec.describe PageMagic::Comparator::ParameterMap do
  describe '#fuzzy?' do
    context 'when one value is fuzzy' do
      it 'returns true' do
        map = described_class.new({ param1: //, param2: '' })
        expect(map).to be_fuzzy
      end
    end

    context 'when all values are literal' do
      it 'returns true' do
        map = described_class.new({ param1: '', param2: '' })
        expect(map).not_to be_fuzzy
      end
    end
  end

  describe '#match?' do
    context 'when param has compatible params' do
      it 'returns true' do
        expect(described_class.new({ param: '1' })).to be_match(param: '1')
      end
    end

    context 'when it does not have compatible params' do
      it 'returns false' do
        expect(described_class.new({ param: '1' })).not_to be_match(param: '2')
      end
    end

    context 'when it does not meet all of the requirements' do
      it 'returns false' do
        expect(described_class.new({ param: '1', another_param: '2' })).not_to be_match(param: '1')
      end
    end
  end

  describe '#<=>' do
    context 'when other is empty' do
      context 'and self is empty' do
        it 'is equal' do
          expect(described_class.new({}) <=> described_class.new({})).to be 0
        end
      end

      context 'self is not empty' do
        it 'is greater' do
          expect(described_class.new({ param: 1 }) <=> described_class.new({})).to be 1
        end
      end
    end

    context 'when other contains matchers' do
      context 'when other has the same number' do
        context 'and matchers are of the same type' do
          it 'is equal' do
            expect(described_class.new({ param: // }) <=> described_class.new({ param: // })).to be 0
          end
        end

        context 'and has less literal matchers' do
          it 'is lesser' do
            expect(described_class.new({ param: '' }) <=> described_class.new({ param: // })).to be 1
          end
        end
      end

      context 'when other has the less' do
        it 'is lesser' do
          expect(described_class.new({ param: // }) <=> described_class.new({})).to be 1
        end
      end
    end
  end
end
