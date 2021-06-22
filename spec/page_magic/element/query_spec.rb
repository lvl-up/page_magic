# frozen_string_literal: true

RSpec.describe PageMagic::Element::Query do
  describe '#execute' do
    it 'calls find' do
      subject = described_class.new
      allow(subject).to receive(:find)

      subject.execute(:capybara_element)
      expect(subject).to have_received(:find).with(:capybara_element)
    end

    context 'when a formatter supplied' do
      it 'uses it' do
        subject = described_class.new
        allow(subject).to receive(:find) { |_r, &formatter| formatter.call(:result) }

        result = subject.execute(:capybara_element) { |capybara_result| "formatter_called_on_#{capybara_result}" }
        expect(result).to eq('formatter_called_on_result')
      end
    end

    context 'when no results are found' do
      subject(:query_class) do
        Class.new(described_class) do
          def find(element)
            element.find('missing')
          end
        end
      end

      it 'Returns `NotFound`' do
        element = PageMagic::Element.load('<html></html>')
        expect(query_class.new.execute(element)).to be_a(PageMagic::Element::NotFound)
      end
    end
  end
end
