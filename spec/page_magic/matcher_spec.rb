module PageMagic
  describe Matcher do

    describe '#can_compute_uri?' do
      # TODO only if path exists and no fuzzy stuff
      pending '#implement me'
    end

    describe 'compute_uri' do
      pending 'implement me'
    end

    describe '#fuzzy?' do
      pending 'implement me'
    end

    describe '#matches?' do
      let(:matching_url) { 'http://www.example.com/path?foo=bar#fragment' }
      let(:incompatible_url) { 'http://www.example.com/mismatch?miss=match#mismatch' }
      context 'path requirement exists' do
        context 'path is literal' do
          subject do
            described_class.new('/path')
          end
          it 'returns true for an exact match' do
            expect(subject.match?(matching_url)).to eq(true)
          end

          it 'returns false when not an exact match' do
            expect(subject.match?(incompatible_url)).to eq(false)
          end
        end

        context 'path is regexp' do
          subject do
            described_class.new(%r{\d})
          end
          it 'returns true for a match on the regexp' do
            expect(subject.match?('3')).to eq(true)
          end

          it 'returns false when regexp is not a match' do
            expect(subject.match?('/mismatch')).to eq(false)
          end
        end
      end


      context 'query string requirement exists' do
        context 'parameter requirement is a literal' do
          subject do
            described_class.new(parameters: {foo: 'bar'})
          end

          it 'returns true for a match on the regexp' do
            expect(subject.match?(matching_url)).to eq(true)
          end

          it 'returns false when regexp is not a match' do
            expect(subject.match?(incompatible_url)).to eq(false)
          end
        end

        context 'parameter requirement is a regexp' do
          subject do
            described_class.new(parameters: {foo: %r{b[a]r}})
          end

          it 'returns true for a match on the regexp' do
            expect(subject.match?(matching_url)).to eq(true)
          end

          it 'returns false when regexp is not a match' do
            expect(subject.match?(incompatible_url)).to eq(false)
          end
        end

      end

      context 'fragment requirement exists' do

        context 'fragment requirement is a literal' do
          subject do
            described_class.new(fragment: 'fragment')
          end

          it 'returns true for a match on the regexp' do
            expect(subject.match?(matching_url)).to eq(true)
          end

          it 'returns false when regexp is not a match' do
            expect(subject.match?(incompatible_url)).to eq(false)
          end
        end

        context 'fragment requirement is a regexp' do
          subject do
            described_class.new(fragment: %r{fragment})
          end

          it 'returns true for a match on the regexp' do
            expect(subject.match?(matching_url)).to eq(true)
          end

          it 'returns false when regexp is not a match' do
            expect(subject.match?(incompatible_url)).to eq(false)
          end
        end
      end
    end
  end
end