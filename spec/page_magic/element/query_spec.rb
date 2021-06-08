# frozen_string_literal: true
RSpec.describe PageMagic::Element::Query do
  include_context 'webapp fixture'

  let(:page) do
    elements_page = Class.new do
      include PageMagic
      url '/elements'
    end
    elements_page.visit(application: rack_app).current_page
  end

  describe '#execute' do
    it 'calls find' do
      subject = described_class.new
      allow(subject).to receive(:find)

      subject.execute(:capybara_element)
      expect(subject).to have_received(:find).with(:capybara_element)
    end

    context 'no results found' do
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
