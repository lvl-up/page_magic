module PageMagic
  class Element
    describe Selector do
      describe '.find' do
        it 'returns the constant with the given name' do
          expect(Selector.find(:css)).to be(described_class::CSS)
        end

        context 'selector not found' do
          it 'raises an exception' do
            expect { Selector.find(:invalid) }.to raise_exception(UnsupportedCriteriaException)
          end
        end
      end

      describe '#build' do
        it 'puts the locator and element type in to the result' do
          expect(subject.build(:field, :locator)).to eq([:locator])
        end

        context 'exact is set to true' do
          subject do
            described_class.new(exact: true)
          end

          it 'includes the requirement for the match to be exact' do
            expect(subject.build(:field, :locator)).to include(exact: true)
          end
        end

        context 'supports_type flag set to true in constructor' do
          subject do
            described_class.new(supports_type: true)
          end
          it 'includes the element type in the result' do
            expect(subject.build(:field, :locator)).to eq(%i[field locator])
          end
        end

        context 'formatter supplied to constructor' do
          subject do
            described_class.new do |param|
              "formatted_#{param}".to_sym
            end
          end
          it 'uses the formatter' do
            expect(subject.build(:field, :locator)).to eq([:formatted_locator])
          end
        end

        context 'name supplied to constructor' do
          subject do
            described_class.new(:css)
          end

          it 'is added to the result' do
            expect(subject.build(:field, :locator)).to eq(%i[css locator])
          end
        end
      end

      describe '#initialize' do
        it 'sets exact to false by default' do
          expect(subject.exact).to eq(false)
        end
      end
    end

    class Selector
      shared_examples 'named selector' do |options|
        it 'adds name to the result' do
          expected = [described_class.name, :locator, options].compact
          expect(described_class.build(:element_type, :locator)).to eq(expected)
        end
      end

      shared_examples 'anonymous selector' do
        it 'does not have a name' do
          expect(described_class.name).to eq(nil)
        end
      end

      shared_examples 'element type selector' do
        it 'adds the element type to the result' do
          expect(described_class.supports_type).to eq(true)
        end
      end

      shared_examples 'non element type selector' do
        it 'adds the element type to the result' do
          expect(described_class.supports_type).to eq(false)
        end
      end

      describe NAME do
        it_behaves_like 'anonymous selector'
        it_behaves_like 'non element type selector'

        it 'formats locators' do
          button_name = 'my_button'
          expect(described_class.build(:button, button_name)).to eq(["*[name='#{button_name}']"])
        end
      end

      describe XPATH do
        it_behaves_like 'named selector'
        it_behaves_like 'non element type selector'
      end

      describe ID do
        it_behaves_like 'named selector'
        it_behaves_like 'non element type selector'
      end

      describe LABEL do
        it_behaves_like 'named selector', exact: true
        it_behaves_like 'non element type selector'
      end

      describe TEXT do
        it_behaves_like 'anonymous selector'
        it_behaves_like 'element type selector'
      end
    end

    context 'integration' do
      include_context :webapp_fixture
      let(:capybara_session) { Capybara::Session.new(:rack_test, rack_app).tap { |s| s.visit('/elements') } }

      it 'finds elements by name' do
        query = QueryBuilder.find(:text_field).build({name: 'field_name'})
        expect(query.execute(capybara_session)[:name]).to eq('field_name')
      end

      it 'finds elements by xpath' do
        query = QueryBuilder.find(:element).build({xpath: '//div/label/input'})
        expect(query.execute(capybara_session)[:name]).to eq('field_name')
      end

      it 'finds elements by id' do
        query = QueryBuilder.find(:text_field).build({id: 'field_id'})
        expect(query.execute(capybara_session)[:name]).to eq('field_name')
      end

      it 'finds elements by label' do
        query = QueryBuilder.find(:text_field).build({label: 'enter text'})
        expect(query.execute(capybara_session)[:name]).to eq('field_name')
      end

      it 'finds elements by text' do
        query = QueryBuilder.find(:link).build({text: 'a link'})
        expect(query.execute(capybara_session).text).to eq('a link')
      end
    end
  end
end
