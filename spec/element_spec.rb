# rubocop:disable Metrics/ModuleLength
module PageMagic
  describe Element do
    include_context :webapp_fixture

    let(:page_class) do
      Class.new do
        include PageMagic
        url '/elements'
      end
    end

    let(:session) { page_class.visit(application: rack_app) }

    let(:page) { session.current_page }

    subject do
      described_class.new(:page_element, page)
    end

    it_behaves_like 'session accessor'
    it_behaves_like 'element watcher'
    it_behaves_like 'waiter'
    it_behaves_like 'element locator'

    describe 'inheriting' do
      it 'lets you create custom elements' do
        custom_element = Class.new(described_class) do
          text_field :form_field, id: 'field_id'

          def self.name
            'Form'
          end
        end

        page_class.class_eval do
          element custom_element, css: '.form'
        end

        expect(page.form.form_field).to be_visible
      end
    end

    describe '#initialize' do
      let!(:browser) { double('browser') }

      it 'sets the parent element' do
        instance = described_class.new(page, :parent_page_element)
        expect(instance.parent_page_element).to eq(:parent_page_element)
      end
    end

    describe 'hooks' do
      subject do
        Class.new(described_class) do
          before_events do
            call_in_before_hook
          end
        end.new(double('button', click: true), page)
      end
      context 'method called in before hook' do
        it 'calls methods on the page element' do
          expect(subject).to receive(:call_in_before_hook)
          subject.click
        end
      end

      context 'method called in after hook' do
        subject do
          Class.new(described_class) do
            after_events do
              call_in_after_hook
            end
          end.new(double('button', click: true), page)
        end

        it 'calls methods on the page element' do
          expect(subject).to receive(:call_in_after_hook)
          subject.click
        end
      end
    end

    describe '#method_missing' do
      before do
        page_class.class_eval do
          element :form_by_css, css: '.form' do
            link(:link_in_form, text: 'a in a form')
          end
        end
      end

      it 'can delegate to capybara' do
        expect(page.form_by_css).to be_visible
      end

      context 'no element definition and not a capybara method' do
        it 'throws and exception' do
          expect { page.form_by_css.bobbins }.to raise_exception NoMethodError
        end
      end
    end

    describe '#respond_to?' do
      subject do
        Class.new(described_class) do
          element :sub_element, css: '.sub-element'
        end.new(double(element_method: ''), :parent_page_element)
      end
      it 'checks for methods on self' do
        expect(subject.respond_to?(:session)).to eq(true)
      end

      it 'checks against registered elements' do
        expect(subject.respond_to?(:sub_element)).to eq(true)
      end

      it 'checks for the method of the browser_element' do
        expect(subject.respond_to?(:element_method)).to eq(true)
      end
    end

    describe '#session' do
      it 'should have a handle to the session' do
        expect(subject.session).to eq(page.session)
      end
    end
  end
end
