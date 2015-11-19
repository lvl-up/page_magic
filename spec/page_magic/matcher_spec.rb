# rubocop:disable Metrics/ModuleLength
module PageMagic
  describe Matcher do
    describe '#initialize' do
      context 'no componentes specified' do
        it 'raises an exeception' do
          expect { described_class.new }.to raise_exception(MatcherInvalidException)
        end
      end
    end
    describe '#can_compute_uri?' do
      context 'regex in path' do
        it 'returns false' do
          expect(described_class.new(//).can_compute_uri?).to eq(false)
        end
      end

      context 'regex in parameters' do
        it 'returns false' do
          expect(described_class.new(parameters: { param: // }).can_compute_uri?).to eq(false)
        end
      end

      context 'regexp in fragment' do
        it 'returns false' do
          expect(described_class.new(fragment: //).can_compute_uri?).to eq(false)
        end
      end

      context 'regexp not present' do
        it 'returns true' do
          expect(described_class.new('/').can_compute_uri?).to eq(true)
        end
      end
    end

    describe 'compare' do
      subject { described_class.new('/') }
      context 'param 1 not nil' do
        context 'param 2 not nil' do
          context 'literal to fuzzy' do
            it 'returns -1' do
              expect(subject.instance_eval { compare('/', //) }).to eq(-1)
            end
          end

          context 'literal to literal' do
            it 'returns 0' do
              expect(subject.instance_eval { compare('/', '/') }).to eq(0)
            end
          end

          context 'fuzzy to fuzzy' do
            it 'returns 0' do
              expect(subject.instance_eval { compare(//, //) }).to eq(0)
            end
          end

          context 'fuzzy to literal' do
            it 'returns 1' do
              expect(subject.instance_eval { compare(//, '/') }).to eq(1)
            end
          end
        end

        context 'param2 is nil' do
          it 'returns -1' do
            expect(subject.instance_eval { compare('/', nil) }).to eq(-1)
          end
        end
      end

      context 'param1 is nil' do
        context 'param2 not nil' do
          it 'returns 1' do
            expect(subject.instance_eval { compare(nil, '/') }).to eq(1)
          end
        end

        context 'param2 nil' do
          it 'returns 0' do
            expect(subject.instance_eval { compare(nil, nil) }).to eq(0)
          end
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
            expect(described_class.new(parameters: { a: 1 }).compute_uri).to eq('?a=1')
          end
        end

        context 'more than 1 param' do
          it 'returns a uri' do
            expect(described_class.new(parameters: { a: 1, b: 2 }).compute_uri).to eq('?a=1&b=2')
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
            described_class.new(parameters: { foo: 'bar' })
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
            described_class.new(parameters: { foo: /b[a]r/ })
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
      it 'compares paths' do
        subject = described_class.new('/')
        expect(subject).to receive(:compare).with('/', nil).and_return(:result)
        expect(subject <=> described_class.new(parameters: {})).to eq(:result)
      end

      context 'paths are equal' do
        it 'compares parameters' do
          subject = described_class.new('/', parameters: :params1)
          expect(subject).to receive(:compare).with('/', '/').and_call_original
          expect(subject).to receive(:compare).with(:params1, :params2).and_return(:params_result)
          expect(subject <=> described_class.new('/', parameters: :params2)).to eq(:params_result)
        end
      end

      context 'parameters are equal' do
        it 'compares fragments' do
          subject = described_class.new('/', parameters: :params, fragment: :frag1)
          expect(subject).to receive(:compare).with('/', '/').and_call_original
          expect(subject).to receive(:compare).with(:params, :params).and_call_original
          expect(subject).to receive(:compare).with(:frag1, :frag2).and_return(:fragment_result)
          expect(subject <=> described_class.new('/', parameters: :params, fragment: :frag2)).to eq(:fragment_result)
        end
      end
    end
  end
end
