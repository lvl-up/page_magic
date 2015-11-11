module PageMagic
  class Element
    describe Query do
      it 'has a predefined query for each element type' do
        missing = PageMagic::Elements::TYPES.find_all do |type|
          !described_class.constants.include?(type.upcase.to_sym)
        end
        expect(missing).to be_empty
      end

      describe '.find' do
        it 'finds the constant with the given name' do
          expect(Query.find(:button)).to be(described_class::BUTTON)
        end

        context 'constant not found' do
          it 'returns a default' do
            expect(Query.find(:billy)).to be(described_class::ELEMENT)
          end
        end
      end

      describe '#build' do
        let(:selector) { Selector.new }
        before do
          expect(Selector).to receive(:find).with(:css).and_return(selector)
        end
        let(:locator) { { css: '.css' } }

        it 'uses the locator to find the correct selector builder' do
          expect(subject.build(locator)).to eq(locator.values)
        end

        it 'adds options to the result' do
          expect(subject.build(locator, :options)).to eq(locator.values.concat([:options]))
        end

        context 'selector support element type' do
          subject do
            described_class.new(:field)
          end

          it 'passes element type through to the selector' do
            expect(selector).to receive(:build).with(:field, '.css').and_call_original
            subject.build(locator)
          end
        end
      end
    end

    class Query
      describe BUTTON do
        it 'has an element type' do
          expect(described_class.type).to eq(:button)
        end
      end

      describe ELEMENT do
        it ' does not has an element type' do
          expect(described_class.type).to be_nil
        end
      end

      describe LINK do
        it 'has an element type' do
          expect(described_class.type).to eq(:link)
        end
      end

      describe TEXT_FIELD do
        it 'has an element type' do
          expect(described_class.type).to eq(:field)
        end

        it 'the same as all form field types' do
          expect(described_class).to eq(CHECKBOX).and eq(SELECT_LIST).and eq(RADIOS).and eq(TEXTAREA)
        end
      end
    end

    context 'integration' do
      include_context :webapp_fixture
      let(:capybara_session) { Capybara::Session.new(:rack_test, rack_app).tap { |s| s.visit('/elements') } }
      it 'finds fields' do
        expect { capybara_session.find(*Query.find(:text_field).build(name: 'field_name')) }.to_not raise_exception
      end

      it 'finds buttons' do
        expect { capybara_session.find(*Query.find(:button).build(text: 'a button')) }.to_not raise_exception
      end

      it 'finds links' do
        expect { capybara_session.find(*Query.find(:link).build(text: 'a link')) }.to_not raise_exception
      end

      it 'finds elements' do
        expect { capybara_session.find(*Query.find(:element).build(name: 'field_name')) }.to_not raise_exception
      end
    end
  end
end
