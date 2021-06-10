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
    it 'sets the selector and type' do
      expected_definition = PageMagic::ElementDefinitionBuilder.new(definition_class: PageMagic::Element,
                                                                    type: :field,
                                                                    selector: child_selector)
      subject.text_field :alias, child_selector
      expect(instance.element_by_name(:alias)).to eq(expected_definition)
    end

    context 'options' do
      it 'builds them in to the query used to find the defined element' do
        options = { my: :options }
        subject.text_field :alias, child_selector, options
        expect(instance.element_by_name(:alias).query.options).to eq(options)
      end
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
          expect(element_definition_builder.definition_class).to be < section_class
        end

        context 'with no selector supplied' do
          it 'defaults the selector to the one on the class' do
            section_class.selector child_selector
            subject.element section_class, :alias
            element_definition_builder = instance.element_by_name(:alias)
            expect(element_definition_builder.query.selector_args).to eq(child_selector.to_a.flatten)
          end
        end

        context 'with no name supplied' do
          it 'defaults to the name of the class if one is not supplied' do
            subject.element section_class, child_selector
            element_definition_builder = instance.element_by_name(:page_section)
            expect(element_definition_builder.definition_class).to be < section_class
          end
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

    describe 'location' do
      context 'a prefetched object' do
        it 'adds a section' do
          subject.element :page_section, :object
          element_defintion_builder = instance.element_by_name(:page_section)
          expect(element_defintion_builder.build(:anything).browser_element).to eq(:object)
        end
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

  describe '#elements' do
    it 'is an alias of #element allowing page_magic to find multiple results' do
      expected = described_class.public_instance_method(:element)
      expect(described_class.public_instance_method(:elements)).to eq(expected)
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
