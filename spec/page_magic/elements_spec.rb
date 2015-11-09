# rubocop:disable Metrics/ModuleLength
module PageMagic
  describe Elements do
    let(:page_elements) do
      Class.new.tap do |clazz|
        clazz.extend(described_class)
      end
    end

    include_context :webapp_fixture

    let(:parent_page_element) do
      Element.new(double(browser_element: nested_element), type: :element, selector: { id: 'parent' }) do
        element :child, id: 'child'
      end
    end

    let(:child_element){parent_page_element.child}
    let(:child_selector) { child_element.selector }


    describe '#element' do
      it 'uses the supplied name' do
        expected_element = Element.new(parent_page_element, type: :text_field, selector: child_selector)
        page_elements.text_field :alias, child_selector
        expect(page_elements.element_by_name(:alias, parent_page_element)).to eq(expected_element)
      end

      it 'sets the parent element' do
        page_elements.text_field :alias, child_selector
        section = page_elements.element_by_name(:alias, parent_page_element)
        expect(section.parent_page_element).to eq(parent_page_element)
      end

      context 'using a selector' do
        it 'should add an element' do
          expected_element = Element.new(parent_page_element, type: :text_field, selector: child_selector)
          page_elements.text_field :name, child_selector
          expect(page_elements.element_by_name(:name, parent_page_element)).to eq(expected_element)
        end
      end

      context 'complex elements' do
        let!(:section_class) do
          Class.new(Element)
        end

        context 'using a predefined class' do
          it 'should add an element using that class section' do
            expected_section = section_class.new(parent_page_element, type: :element, selector: child_selector)

            page_elements.element section_class, :page_section, child_selector
            expect(page_elements.elements(parent_page_element).first).to eq(expected_section)
          end

          context 'with no selector supplied' do
            it 'defaults the selector to the one on the class' do
              section_class.selector child_selector
              page_elements.element section_class, :alias
              expect(page_elements.elements(parent_page_element).first.selector).to eq(child_selector)
            end
          end

          context 'with no name supplied' do
            it 'should default to the name of the class if one is not supplied' do
              expected_element = Element.new(parent_page_element, selector: child_selector)
              allow(section_class).to receive(:name).and_return('PageSection')
              page_elements.element section_class, child_selector
              expect(page_elements.element_by_name(:page_section, parent_page_element)).to eq(expected_element)
            end
          end
        end
      end

      context 'using a block' do
        context 'browser_element' do

          it 'should be assigned when selector is passed to section method' do
            expected_element = child_element.browser_element.native

            page_elements.element :page_section, child_selector do
              extend RSpec::Matchers
              expect(browser_element.native).to eq(expected_element)
            end

            page_elements.element_by_name(:page_section, parent_page_element)
          end

          it 'should be assigned when selector is defined in the block passed to the section method' do
            expected_element = child_element

            page_elements.element :page_section do
              selector expected_element.selector
              extend RSpec::Matchers
              expect(browser_element.native).to eq(expected_element.browser_element.native)
            end

            page_elements.elements(parent_page_element)
          end
        end

        it 'should pass args through to the block' do
          page_elements.element :page_section, css: '.blah' do |arg|
            arg[:passed_through] = true
          end

          arg = {}
          browser = double('browser', find: :browser_element)
          parent_page_element = double('parent_browser_element', browser_element: browser)
          page_elements.elements(parent_page_element, arg)
          expect(arg[:passed_through]).to eq(true)
        end
      end

      describe 'location' do
        context 'a prefetched object' do
          it 'should add a section' do
            expected_section = Element.new(parent_page_element,
                                           type: :element,
                                           prefetched_browser_element: :object)
            page_elements.element :page_section, :object
            expect(expected_section).to eq(page_elements.elements(parent_page_element).first)
          end
        end
      end

      describe 'restrictions' do
        it 'should not allow method names that match element names' do
          expect do
            page_elements.class_eval do
              link(:hello, text: 'world')

              def hello
              end
            end
          end.to raise_error(InvalidMethodNameException)
        end

        it 'should not allow element names that match method names' do
          expect do
            page_elements.class_eval do
              def hello
              end

              link(:hello, text: 'world')
            end
          end.to raise_error(InvalidElementNameException)
        end

        it 'should not allow duplicate element names' do
          expect do
            page_elements.class_eval do
              link(:hello, text: 'world')
              link(:hello, text: 'world')
            end
          end.to raise_error(InvalidElementNameException)
        end

        it 'should not evaluate the elements when applying naming checks' do
          page_elements.class_eval do
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
        page_elements.text_field :name, child_selector
        first = page_elements.element_by_name(:name, parent_page_element)
        second = page_elements.element_by_name(:name, parent_page_element)
        expect(first).to_not equal(second)
      end
    end
  end
end
