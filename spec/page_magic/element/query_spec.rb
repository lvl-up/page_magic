# frozen_string_literal: true
RSpec.describe PageMagic::Element::Query do
  include_context 'webapp fixture'

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

        allow(subject).to receive(:find) do |result, &formatter|
          formatter.call(result)
        end

        result = subject.execute(:capybara_element) do |result|
          expect(result).to eq(:result)
          :formatter_called
        end

        expect(result).to eq(:formatter_called)
      end
    end

    context 'when no results are found' do
      it 'raises an error' do
        subject = Class.new(described_class) do
          def find(element)
            element.find('wrong')
          end
        end.new

        expected_message = 'Unable to find css "wrong"'

        expect do
          subject.execute(page.browser)
        end.to raise_exception(PageMagic::ElementMissingException, expected_message)
      end
    end
  end
end
