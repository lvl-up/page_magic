# frozen_string_literal: true

RSpec.describe PageMagic::Elements do
  subject do
    Class.new do
      extend PageMagic::Elements
      include PageMagic::Element::Locators
    end
  end

  include_context 'nested elements html'

  let(:page) { double(init: nested_elements_node) }
  let(:instance) do
    subject.new
  end
  let(:child_selector) { { id: 'child' } }

  context 'element types' do
    it 'provides all of the type provided by capybara' do
      capybara_elements = Capybara::Selector.all.except(*%i[element datalist_input datalist_option id xpath css]).keys
      expect(described_class::TYPES).to include(*capybara_elements)
    end
  end

  describe '#element' do
    it 'converts arguments in to options' do
      allow(PageMagic::Elements::Options)
        .to receive(:build)
          .with([:alias, child_selector,{visible:true }], :text_field)
            .and_call_original
      subject.text_fields :alias, child_selector, visible: true
    end

    context 'complex elements' do
      let!(:section_class) do
        Class.new(PageMagic::Element) do
          def self.name
            'PageSection'
          end
        end
      end

      context 'using a predefined class' do
        it 'adds an element using that class section' do
          subject.element section_class, :page_section, child_selector
          element_definition_builder = instance.element_by_name(:page_section)
          expect(element_definition_builder.send(:definition_class)).to be < section_class
        end
      end
    end

    context 'using a block' do
      it 'passes the parent element in as the last argument' do
        expected_element = instance
        subject.element :page_section, child_selector do |_arg1|
          extend RSpec::Matchers
          expect(parent_element).to eq(expected_element)
        end
        instance.element_by_name(:page_section, :arg1)
      end

      it 'passes args through to the block' do
        subject.element :page_section, child_selector do |arg|
          extend RSpec::Matchers
          expect(arg).to eq(:arg1)
        end

        instance.element_by_name(:page_section, :arg1)
      end
    end

    describe 'restrictions' do
      subject do
        Class.new.tap do |clazz|
          clazz.extend(described_class)
        end
      end

      it 'does not allow method names that match element names' do
        expect do
          subject.class_eval do
            link(:hello, text: 'world')

            def hello; end
          end
        end.to raise_error(PageMagic::InvalidMethodNameException)
      end

      it 'does not allow element names that match method names' do
        expect do
          subject.class_eval do
            def hello; end

            link(:hello, text: 'world')
          end
        end.to raise_error(PageMagic::InvalidElementNameException)
      end

      it 'does not allow duplicate element names' do
        expect do
          subject.class_eval do
            link(:hello, text: 'world')
            link(:hello, text: 'world')
          end
        end.to raise_error(PageMagic::InvalidElementNameException)
      end

      it 'does not evaluate the elements when applying naming checks' do
        subject.class_eval do
          link(:link1, :selector) do
            raise('should not have been evaluated')
          end
          link(:link2, :selector)
        end
      end
    end
  end

  describe '#element_definitions' do
    it 'returns your a copy of the core definition' do
      subject.text_field :alias, child_selector
      first = instance.element_by_name(:alias)
      second = instance.element_by_name(:alias)
      expect(first).not_to equal(second)
    end
  end

  # TODO - test that element type is support correctly
  # it 'has a predefined query for each element type' do
  #   missing = PageMagic::Elements::TYPES.dup.delete_if { |type| type.to_s.end_with?('s') }.find_all do |type|
  #     described_class.constants.include?(type)
  #   end
  #   expect(missing).to be_empty
  # end
end
