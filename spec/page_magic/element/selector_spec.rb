# frozen_string_literal: true

RSpec.describe PageMagic::Element::Selector do
  describe '.find' do
    it 'returns the constant with the given name' do
      expect(described_class.find(:css)).to be(described_class::CSS)
    end

    context 'when selector not found' do
      it 'raises an exception' do
        expect { described_class.find(:invalid) }.to raise_exception(PageMagic::UnsupportedCriteriaException)
      end
    end
  end

  describe '#build' do
    it 'puts the locator and element type in to the result' do
      expect(subject.build(:field, :locator)).to have_attributes(
        args: [:locator]
      )
    end

    context 'when exact matching is required' do
      subject do
        described_class.new(exact: true)
      end

      it 'is added to options' do
        expect(subject.build(:field, :locator)).to have_attributes(
          options: { exact: true }
        )
      end
    end

    context 'when supports_type true' do
      subject do
        described_class.new(supports_type: true)
      end

      it 'includes the element type' do
        expect(subject.build(:field, :locator)).to have_attributes(
          args: %i[field locator]
        )
      end
    end

    # TODO - new class?
    context 'when selector formatter is provided' do
      subject do
        described_class.new do |param|
          "formatted_#{param}".to_sym
        end
      end

      it 'uses the formatter' do
        expect(subject.build(:field, :locator)).to have_attributes(
          args: [:formatted_locator]
        )
      end
    end

    context 'when type supplied' do
      subject do
        described_class.new(:css)
      end

      it 'is added to the result' do
        expect(subject.build(:field, :locator)).to have_attributes(
          args: %i[css locator]
        )
      end
    end
  end

  describe '#initialize' do
    context 'when exact' do
      it 'sets the option' do
        subject = described_class.new(exact: true).build(:element_type, {})
        expect(subject.options).to eq({ exact: true } )
      end
    end
  end

  describe 'predefined selectors' do
    shared_examples 'a selector' do |named: false, **options|
      def selector_name
        self.class.metadata[:parent_example_group][:description].to_sym
      end

      subject do
        described_class.find(selector_name).build(:element_type, :locator)
      end

      it 'contains the selector args' do
        name_arg = if named
                     named == true ? selector_name : named
                   end

        expected_args = [name_arg, :locator].compact
        expect(subject.args).to eq(expected_args)
        expect(subject.options).to eq(options)
      end
    end

    include_context 'webapp fixture', path: '/elements'

    describe 'label' do
      it_behaves_like 'a selector', named: :field, exact: true

      it 'finds elements by label' do
        query = PageMagic::Element::QueryBuilder.find(:text_field).build({ label: 'enter text' })
        expect(query.execute(capybara_session)[:name]).to eq('field_name')
      end
    end

    describe 'name' do
      it 'formats locators' do
        name = 'my_button'
        expect(described_class::NAME.build(:element_type, name)).to have_attributes(
          args: ["*[name='#{name}']"],
          options: {}
        )
      end

      it 'finds elements by name' do
        query = PageMagic::Element::QueryBuilder.find(:text_field).build({ name: 'field_name' })
        expect(query.execute(capybara_session)[:name]).to eq('field_name')
      end
    end

    context 'xpath' do
      it_behaves_like 'a selector', named: true

      it 'finds elements by xpath' do
        query = PageMagic::Element::QueryBuilder.find(:element).build({ xpath: '//div/label/input' })
        expect(query.execute(capybara_session)[:name]).to eq('field_name')
      end
    end

    describe 'id' do
      it_behaves_like 'a selector', named: true

      it 'finds elements by id' do
        query = PageMagic::Element::QueryBuilder.find(:text_field).build({ id: 'field_id' })
        expect(query.execute(capybara_session)[:name]).to eq('field_name')
      end
    end

    describe 'label' do
      it_behaves_like 'a selector', named: :field, exact: true
    end

    describe 'text' do
      it_behaves_like 'a selector', named: :element_type

      it 'finds elements by text' do
        query = PageMagic::Element::QueryBuilder.find(:link).build({ text: 'a link' })
        expect(query.execute(capybara_session).text).to eq('a link')
      end
    end
  end
end
