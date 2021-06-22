# frozen_string_literal: true

RSpec.describe PageMagic::ElementContext do
  describe '#method_missing' do
    let(:element_class) do
      Class.new(PageMagic::Element)
    end

    context 'when method is a element definition' do
      it 'returns the sub page element' do
        element_class.link(:a_link, text: 'a link')
        element = described_class.new(element_class.load("<a href='#'>a link</a>")).a_link
        expect(element.text).to eq('a link')
      end

      it 'passes arguments through to the element definition' do
        element_class.link(:pass_through, css: 'a') { |args| args[:passed_through] = true }

        args = {}
        described_class.new(element_class.load("<a href='#'>a link</a>")).pass_through(args)
        expect(args[:passed_through]).to eq(true)
      end

      it 'does not evaluate any of the other definitions' do
        element_class.link(:a_link, text: 'a link')
        element_class.link(:another_link, :selector) { raise('should not have been evaluated') }

        described_class.new(element_class.load("<a href='#'>a link</a>")).a_link
      end
    end

    context 'when the method is found on page_element' do
      it 'calls page_element method' do
        element_class.define_method(:page_method) do
          :called
        end

        expect(described_class.new(element_class.load("<a href='#'>a link</a>")).page_method).to eq(:called)
      end
    end

    context 'when the method is not found on page_element or as a element definition' do
      it 'raises an error' do
        expect do
          described_class.new(PageMagic::Element.load('')).missing_method
        end.to raise_error(PageMagic::ElementMissingException)
      end
    end
  end

  describe '#respond_to?' do
    let(:page_element_class) do
      Class.new(PageMagic::Element) do
        link(:a_link, text: 'a link')
      end
    end

    context 'when the page_element responds to method name' do
      it 'returns true' do
        element = described_class.new(page_element_class.load("<a href='#'>a link</a>"))
        expect(element).to respond_to(:a_link)
      end
    end

    context 'when the method is not on the page_element' do
      it 'calls super' do
        element = described_class.new(page_element_class.load("<a href='#'>a link</a>")).a_link
        expect(element.text).to respond_to(:methods)
      end
    end
  end
end
