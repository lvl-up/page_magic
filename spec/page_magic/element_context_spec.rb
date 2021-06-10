# frozen_string_literal: true

RSpec.describe PageMagic::ElementContext do
  include_context 'webapp fixture'

  def visit(klass)
    klass.visit(application: rack_app).current_page
  end

  describe '#method_missing' do
    let!(:elements_page_class) do
      Class.new do
        include PageMagic
        url '/elements'
        link(:a_link, text: 'a link')
      end
    end

    context 'method is a element defintion' do
      it 'returns the sub page element' do
        page = visit(elements_page_class)

        element = described_class.new(page).a_link
        expect(element.text).to eq('a link')
      end

      it 'passes arguments through to the element definition' do
        elements_page_class.links :pass_through, css: 'a' do |args|
          args[:passed_through] = true
        end
        page = visit(elements_page_class)

        args = {}
        described_class.new(page).pass_through(args)
        expect(args[:passed_through]).to eq(true)
      end

      it 'does not evaluate any of the other definitions' do
        elements_page_class.link(:another_link, :selector) do
          raise('should not have been evaluated')
        end

        page = visit(elements_page_class)
        described_class.new(page).a_link
      end

      context 'more than one match found in the browser' do
        it 'returns an array of element definitions' do
          elements_page_class.links :links, css: 'a'

          page = visit(elements_page_class)
          links = described_class.new(page).links
          expect(links.find_all { |e| e.is_a?(PageMagic::Element) }.size).to eq(2)
          expect(links.collect(&:text)).to eq(['a link', 'link in a form'])
        end
      end
    end

    context 'method found on page_element' do
      it 'calls page_element method' do
        elements_page_class.class_eval do
          def page_method
            :called
          end
        end
        page = visit(elements_page_class)
        expect(described_class.new(page).page_method).to eq(:called)
      end
    end

    context 'method not found on page_element or as a element definition' do
      it 'raises an error' do
        expect { elements_page_class.missing_method }.to raise_error(NoMethodError)
      end
    end
  end

  describe '#respond_to?' do
    let(:page_element_class) do
      Class.new(PageMagic::Element) do
        link(:a_link, css: '.link')
      end
    end

    subject do
      session = double('session', raw_session: double('browser'))
      described_class.new(page_element_class.new(session))
    end

    context 'page_element responds to method name' do
      it 'returns true' do
        expect(subject.respond_to?(:a_link)).to eq(true)
      end
    end

    context 'method is not on page_element' do
      it 'calls super' do
        expect(subject.respond_to?(:methods)).to eq(true)
      end
    end
  end
end
