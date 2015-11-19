module PageMagic
  describe Matcher do
    describe '#can_compute_uri?' do
      context 'regex in path' do
        it 'returns false' do
          expect(described_class.new(//).can_compute_uri?).to eq(false)
        end
      end

      context 'regex in parameters' do
        it 'returns false' do
          expect(described_class.new(parameters: {param: //}).can_compute_uri?).to eq(false)
        end
      end

      context 'regexp in fragment' do
        it 'returns false' do
          expect(described_class.new(fragment: //).can_compute_uri?).to eq(false)
        end
      end

      context 'regexp not present' do
        it 'returns true' do
          expect(described_class.new.can_compute_uri?).to eq(true)
        end
      end
    end

    describe 'compute_uri' do
      context 'path present' do
        it 'returns a uri' do
          expect(described_class.new('/').compute_uri).to eq('/')
        end
      end

      context 'params present' do
        context '1 param' do
          it 'returns a uri' do
            expect(described_class.new(parameters: {a: 1}).compute_uri).to eq('?a=1')
          end
        end

        context 'more than 1 param' do
          it 'returns a uri' do
            expect(described_class.new(parameters: {a: 1, b: 2}).compute_uri).to eq('?a=1&b=2')
          end
        end
      end

      context 'fragment present' do
        it 'returns a uri' do
          expect(described_class.new(fragment: 'fragment').compute_uri).to eq('#fragment')
        end
      end
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
            described_class.new(/\d/)
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

          it 'returns true for a match' do
            expect(subject.match?(matching_url)).to eq(true)
          end

          it 'returns false when regexp is not a match' do
            expect(subject.match?(incompatible_url)).to eq(false)
          end
        end

        context 'parameter requirement is a regexp' do
          subject do
            described_class.new(parameters: {foo: /b[a]r/})
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

          it 'returns true for a match' do
            expect(subject.match?(matching_url)).to eq(true)
          end

          it 'returns false when regexp is not a match' do
            expect(subject.match?(incompatible_url)).to eq(false)
          end
        end

        context 'fragment requirement is a regexp' do
          subject do
            described_class.new(fragment: /fragment/)
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

    describe '<=>' do
      context 'self has path' do
        context 'other has path' do
          context 'literal to fuzzy' do
            it 'returns -1' do
              expect(described_class.new('/') <=> described_class.new(%r{})).to eq(-1)
            end
          end

          context 'literal to literal' do
            it 'returns 0' do
              expect(described_class.new('/') <=> described_class.new('/')).to eq(0)
            end
          end

          context 'fuzzy to fuzzy' do
            it 'returns 0' do
              expect(described_class.new(%r{}) <=> described_class.new(%r{})).to eq(0)
            end
          end

          context 'fuzzy to literal' do
            it 'returns 1' do
              expect(described_class.new(%r{}) <=> described_class.new('/')).to eq(1)
            end
          end
        end

        context 'other does not have path' do
          it 'returns -1' do
            expect(described_class.new('/') <=> described_class.new).to eq(-1)
          end
        end
      end

      context 'self does not have path' do
        context 'other does have path' do
          it 'returns 1' do
            expect(described_class.new <=> described_class.new('/')).to eq(1)
          end
        end

        context 'other does not have path' do
          it 'returns 0' do
            expect(described_class.new <=> described_class.new).to eq(0)
          end
        end
      end

      context 'self has parameters' do
        context 'other has parameters' do
          context 'literal to literal' do
            it 'returns 0' do
              expect(described_class.new(parameters: {'/' => :mapping}) <=> described_class.new(parameters: {'/' => :mapping})).to eq(0)
            end
          end

          context 'literal to fuzzy' do
            it 'returns -1' do
              expect(described_class.new(parameters: {'/' => :mapping}) <=> described_class.new(parameters: {%r{} => :mapping})).to eq(-1)
            end
          end

          context 'fuzzy to literal' do
            it 'returns -1' do
              expect(described_class.new(parameters: {%r{} => :mapping}) <=> described_class.new(parameters: {'/' => :mapping}) ).to eq(1)
            end
          end

          context 'fuzzy to fuzzy' do
            it 'returns 0' do
              expect(described_class.new(parameters: {%r{} => :mapping}) <=> described_class.new(parameters: {%r{} => :mapping}) ).to eq(0)
            end
          end

          context 'literal to literal' do
            it 'returns 0' do
              expect(described_class.new(parameters: {'/' => :mapping}) <=> described_class.new(parameters: {'/' => :mapping}) ).to eq(0)
            end
          end
        end

        context 'other does not have parameters' do
          it 'returns -1' do
            expect(described_class.new(parameters: {'/' => :mapping}) <=> described_class.new).to eq(-1)
          end
        end


      end
    end

    describe 'score' do
      context 'has path' do
        context 'literal' do
          it 'scores 2' do
            expect(described_class.new('/').score).to eq(2)
          end
        end

        context 'regexp' do
          it 'returns 1' do
            expect(described_class.new(%r{}).score).to eq(1)
          end
        end
      end

      context 'has parameters' do
        context 'literal' do
          it 'returns 2 per literal' do
            expect(described_class.new(parameters: {a: '1', b: '2'}).score).to eq(4)
          end
        end

        context 'regexp' do
          it 'returns 2 per regexp' do
            expect(described_class.new(parameters: {a: %r{}, b: %r{}}).score).to eq(2)
          end
        end
      end

      context 'has fragment' do
        context 'literal' do
          it 'scores 2' do
            expect(described_class.new(fragment: 'fragment').score).to eq(2)
          end
        end

        context 'regexp' do
          it 'returns 1' do
            expect(described_class.new(fragment: %r{}).score).to eq(1)
          end
        end
      end
    end
  end
end
