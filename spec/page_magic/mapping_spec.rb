# frozen_string_literal: true

RSpec.describe PageMagic::Mapping do
  describe '#can_compute_uri?' do
    context 'when there is a regex in the path' do
      it 'returns false' do
        expect(described_class.new(//).can_compute_uri?).to eq(false)
      end
    end

    context 'when there is a regex in `parameters`' do
      it 'returns false' do
        expect(described_class.new(parameters: { param: // }).can_compute_uri?).to eq(false)
      end
    end

    context 'when there is a regexp in `fragment`' do
      it 'returns false' do
        expect(described_class.new(fragment: //).can_compute_uri?).to eq(false)
      end
    end

    context 'when matching element is a regexp' do
      it 'returns true' do
        expect(described_class.new('/').can_compute_uri?).to eq(true)
      end
    end
  end

  describe '<=>' do
    context 'when other does not have a `path`' do
      it 'is greater' do
        expect(described_class.new('/') <=> described_class.new(parameters: {})).to be 1
      end
    end

    context 'other has a `path`' do
      it 'compares them' do
        expect(described_class.new('/', parameters: { param: 1 }) <=> described_class.new('/')).to be 1
      end

      context 'other has does not have a fragment' do
        it 'is lesser' do
          expect(described_class.new('/', parameters: { param: 1 },
                                          fragment: '') <=> described_class.new('/', parameters: { param: 1 })).to be 1
        end
      end

      context 'other has a fragment' do
        it 'is compares them' do
          expect(described_class.new('/', parameters: { param: 1 },
                                          fragment: '') <=> described_class.new('/', parameters: { param: 1 },
                                                                                     fragment: //)).to be 1
        end
      end
    end
  end

  describe 'compute_uri' do
    context 'when path present' do
      it 'returns a uri' do
        expect(described_class.new('/').compute_uri).to eq('/')
      end
    end

    context 'when matching on parameters' do
      context 'when matching on 1 parameter' do
        it 'returns a uri' do
          expect(described_class.new(parameters: { a: 1 }).compute_uri).to eq('?a=1')
        end
      end

      context 'when matching on more than 1 parameter' do
        it 'returns a uri' do
          expect(described_class.new(parameters: { a: 1, b: 2 }).compute_uri).to eq('?a=1&b=2')
        end
      end
    end

    context 'when matching on a fragment' do
      it 'returns a uri' do
        expect(described_class.new(fragment: 'fragment').compute_uri).to eq('#fragment')
      end
    end
  end

  describe '#matches?' do
    let(:matching_url) { 'http://www.example.com/path?foo=bar#fragment' }
    let(:incompatible_url) { 'http://www.example.com/mismatch?miss=match#mismatch' }

    context 'when matching on path' do
      context 'when using a literal' do
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

      context 'when using a regexp' do
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

    context 'when matching on the query string' do
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

      context 'when matching on parameters' do
        subject do
          described_class.new(parameters: { foo: /bar/ })
        end

        it 'returns true for a match on the regexp' do
          expect(subject.match?(matching_url)).to eq(true)
        end

        it 'returns false when regexp is not a match' do
          expect(subject.match?(incompatible_url)).to eq(false)
        end
      end
    end

    context 'when matching on the fragment' do
      context 'when the fragment requirement is a literal' do
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

      context 'when the fragment requirement is a regexp' do
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
end
