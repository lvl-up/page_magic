RSpec.describe PageMagic::Elements::Config do
  describe '.build' do
    it 'sets of the type' do
      options = described_class.build([], :field)
      expect(options.type).to eq(:field)
    end

    it 'sets the options' do
      user_options = { option: 1 }
      options = described_class.build([{ :id => "child" }, user_options], :field)
      expect(options.options).to eq(user_options)
    end

    describe 'name' do
      context 'when supplied' do
        it 'sets it' do
          options = described_class.build([:name], :field)
          expect(options.name).to eq(:name)
        end

        context 'when an element class supplied' do
          it 'uses the supplied name' do
            element_class = Class.new(PageMagic::Element) do
              selector({ css: 'class' })
              def self.name
                'PageSection'
              end
            end

            options = described_class.build([:supplied_name, element_class], :field)
            expect(options.name).to eq(:supplied_name)
          end
        end
      end

      context 'when not supplied' do
        context 'when an element class supplied' do
          it 'uses the name of the class' do
            element_class = Class.new(PageMagic::Element) do
              selector({ css: 'class' })
              def self.name
                'PageSection'
              end
            end

            options = described_class.build([element_class], :field)
            expect(options.name).to eq(:page_section)
          end
        end
      end
    end

    describe 'selector' do
      context 'when selector supplied' do
        it 'sets the selector' do
          options = described_class.build([{ :id => "child" }], :field)
          expect(options.selector).to eq(PageMagic::Element::Selector.find(:id).build(:field, 'child'))
        end

        context 'when page_element class supplied' do
          it 'uses the selector on the class' do
            expected_selector = { css: 'class' }
            element_class = Class.new(PageMagic::Element) do
              selector({ css: 'class' })
              def self.name
                'PageSection'
              end
            end
            options = described_class.build([element_class, expected_selector], :field)

            expect(options.selector).to eq(PageMagic::Element::Selector.find(:css).build(:field, 'class'))
          end
        end
      end

      context 'when no selector supplied' do
        context 'when page_element class supplied' do
          it 'uses the selector on the class' do

            element_class = Class.new(PageMagic::Element) do
              selector({ css: 'class' })

              def self.name
                'PageSection'
              end
            end
            options = described_class.build([element_class], :field)

            expect(options.selector).to eq(PageMagic::Element::Selector.find(:css).build(:field, 'class'))
          end

        end

      end

    end

    it 'sets prefetched options' do
      options = described_class.build([:page_section, :prefetched_element], :field)
      expect(options.element).to eq(:prefetched_element)
    end

    context 'complex elements' do
      let!(:element_class) do
        Class.new(PageMagic::Element) do
          def self.name
            'PageSection'
          end
        end
      end
    end

  end

  describe '.validate!' do
    let(:options) do
      {
        type: :type,
        selector: {css: 'css'},
        element: :object,
        element_class: Class.new(PageMagic::Element)
      }
    end

    describe 'selector' do
      context 'when nil' do
        context 'and prefetched `element` is nil' do
          it 'raise an error' do
            subject = described_class.new(options.except(:selector, :element))
            expect{subject.validate!}.to raise_exception(PageMagic::InvalidConfigurationException,
                                                         described_class::INVALID_SELECTOR_MSG)
          end
        end

        context 'when `element` is not nil' do
          it 'does not raise an error' do
            subject = described_class.new(options.except(:selector))
            expect{subject.validate!}.not_to raise_exception
          end
        end
      end

      context 'when is empty hash' do
        it 'raises an error' do
          subject = described_class.new(options.update(selector: {}).except(:element))
          expect{subject.validate!}.to raise_exception(PageMagic::InvalidConfigurationException,
                                                       described_class::INVALID_SELECTOR_MSG)
        end
      end

      context 'when defined on both class and as parameter' do
        it 'uses the supplied selector' do
          element_class = Class.new(PageMagic::Element) do
            selector css: 'selector'
          end

          subject = described_class.new(options.update(element_class: element_class))
          expect{subject.validate!}.not_to raise_exception
        end
      end

    end


    context 'when type nil' do
      it 'raise an error' do
        subject = described_class.new(options.except(:type))
        expect{subject.validate!}.to raise_exception(PageMagic::InvalidConfigurationException,
                                                     described_class::TYPE_REQUIRED_MESSAGE)
      end
    end

    describe '`element_class`' do
      context 'when nil' do
        it 'raise and error' do
          subject = described_class.new(options.except(:element_class))
          expect{subject.validate!}.to raise_exception(PageMagic::InvalidConfigurationException,
                                                       described_class::INVALID_ELEMENT_CLASS_MSG)
        end
      end

      context 'not a type of `PageMagic::Element`' do
        it 'raise and error' do
          subject = described_class.new(options.update(element_class: Object))
          expect{subject.validate!}.to raise_exception(PageMagic::InvalidConfigurationException,
                                                       described_class::INVALID_ELEMENT_CLASS_MSG)
        end
      end
    end


  end

  describe '#selector' do
    it 'returns a selector' do
      input_options = {
        type: :type,
        selector: {css: 'css'},
        options: {a: :b},
        element: :object,
        element_class: Class.new(PageMagic::Element)
      }
      options = described_class.new(input_options)
      expect(options.selector).to eq(PageMagic::Element::Selector.find(:css).build(:type, 'css', options: {a: :b}))
    end
  end
end
