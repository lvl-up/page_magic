# rubocop:disable Metrics/ModuleLength
module PageMagic
  describe Elements do

    include_context :webapp_fixture

    subject do
      Class.new.tap do |clazz|
        clazz.extend(described_class)
      end
    end

    let(:parent_element) do
      Element.new(double(browser_element: nested_element), type: :element, selector: { id: 'parent' }) do
        element :child, id: 'child'
      end
    end

    let(:child_element) { parent_element.child }
    let(:child_selector) { child_element.selector }

    def expected_element(type)
      Element.new(parent_element, type: type, selector: child_selector)
    end

    describe '#element' do
      it 'uses the supplied name' do
        subject.text_field :alias, child_selector
        expect(subject.element_by_name(:alias, parent_element)).to eq(expected_element(:text_field))
      end

      it 'sets the parent element' do
        subject.text_field :alias, child_selector
        section = subject.element_by_name(:alias, parent_element)
        expect(section.parent_page_element).to eq(parent_element)
      end

      it 'sets the selector' do
        subject.text_field :name, child_selector
        set_selector = subject.element_by_name(:name, parent_element).selector
        expect(set_selector).to eq(expected_element(:text_field).selector)
      end

      context 'complex elements' do
        let!(:section_class) do
          Class.new(Element) do
            def self.name
              'PageSection'
            end
          end
        end

        context 'using a predefined class' do
          it 'should add an element using that class section' do
            subject.element section_class, :page_section, child_selector
            expect(subject.elements(parent_element).first).to eq(expected_element(:element))
          end

          context 'with no selector supplied' do
            it 'defaults the selector to the one on the class' do
              section_class.selector child_selector
              subject.element section_class, :alias
              expect(subject.elements(parent_element).first.selector).to eq(child_selector)
            end
          end

          context 'with no name supplied' do
            it 'should default to the name of the class if one is not supplied' do
              subject.element section_class, child_selector
              expect(subject.element_by_name(:page_section, parent_element)).to eq(expected_element(:element))
            end
          end
        end
      end

      context 'using a block' do
        context 'browser_element' do
          it 'should be assigned when selector is passed to section method' do
            expected_element = child_element.browser_element.native

            subject.element :page_section, child_selector do
              extend RSpec::Matchers
              expect(browser_element.native).to eq(expected_element)
            end

            subject.element_by_name(:page_section, parent_element)
          end

          it 'should be assigned when selector is defined in the block passed to the section method' do
            expected_element = child_element

            subject.element :page_section do
              selector expected_element.selector
              extend RSpec::Matchers
              expect(browser_element.native).to eq(expected_element.browser_element.native)
            end

            subject.elements(parent_element)
          end
        end

        it 'should pass args through to the block' do
          subject.element :page_section, child_selector do |arg|
            arg[:passed_through] = true
          end

          arg = {}
          subject.elements(parent_element, arg)
          expect(arg[:passed_through]).to eq(true)
        end
      end

      describe 'location' do
        context 'a prefetched object' do
          it 'should add a section' do
            expected_section = Element.new(parent_element,
                                           type: :element,
                                           prefetched_browser_element: :object)
            subject.element :page_section, :object
            expect(expected_section).to eq(subject.elements(parent_element).first)
          end
        end
      end

      describe 'restrictions' do
        it 'should not allow method names that match element names' do
          expect do
            subject.class_eval do
              link(:hello, text: 'world')

              def hello
              end
            end
          end.to raise_error(InvalidMethodNameException)
        end

        it 'should not allow element names that match method names' do
          expect do
            subject.class_eval do
              def hello
              end

              link(:hello, text: 'world')
            end
          end.to raise_error(InvalidElementNameException)
        end

        it 'should not allow duplicate element names' do
          expect do
            subject.class_eval do
              link(:hello, text: 'world')
              link(:hello, text: 'world')
            end
          end.to raise_error(InvalidElementNameException)
        end

        it 'should not evaluate the elements when applying naming checks' do
          subject.class_eval do
            link(:link1, :selector) do
              fail('should not have been evaluated')
            end
            link(:link2, :selector)
          end
        end
      end
    end

    describe '#element_definitions' do
      it 'should return your a copy of the core definition' do
        subject.text_field :name, child_selector
        first = subject.element_by_name(:name, parent_element)
        second = subject.element_by_name(:name, parent_element)
        expect(first).to_not equal(second)
      end
    end
  end
end
