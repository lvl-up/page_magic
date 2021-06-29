# frozen_string_literal: true

RSpec.describe PageMagic::Transitions do
  describe '#mapped_page' do
    context 'when a match is match found' do
      it 'returns the page class' do
        mappings = described_class.new('/page' => :mapped_page_using_string)
        expect(mappings.mapped_page('/page')).to be(:mapped_page_using_string)
      end
    end

    context 'when more than one match is found' do
      it 'returns the most specific match' do
        mappings = described_class.new(%r{/page} => :mapped_page_using_regex, '/page' => :mapped_page_using_string)
        expect(mappings.mapped_page('/page')).to eq(:mapped_page_using_string)
      end
    end

    context 'when a mapping is not found' do
      it 'returns nil' do
        mappings = described_class.new({})
        expect(mappings.mapped_page('/unmapped_page')).to be(nil)
      end
    end
  end

  describe '#url_for' do
    it 'returns the url for the mapped page' do
      page = Object.new
      mappings = described_class.new('/mapping' => page)
      expect(mappings.url_for(page, base_url: 'http://base.url')).to eq('http://base.url/mapping')
    end

    context 'when page mapping is a regular expression' do
      it 'raises an error' do
        page = Object.new
        mappings = described_class.new(/mapping/ => page)
        expect { mappings.url_for(page, base_url: 'http://base.url') }
          .to raise_exception PageMagic::InvalidURLException, described_class::REGEXP_MAPPING_MSG
      end
    end
  end
end
