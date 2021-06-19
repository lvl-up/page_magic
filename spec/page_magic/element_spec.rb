# frozen_string_literal: true

RSpec.describe PageMagic::Element do
  let(:described_class) do
    Class.new(PageMagic::Element) # rubocop:disable RSpec/DescribedClass
  end

  it_behaves_like 'session accessor'
  it_behaves_like 'element watcher'
  it_behaves_like 'waiter'
  it_behaves_like 'element locator'

  describe '.after_events' do
    context 'when a hook is registered' do
      it 'returns that hook' do
        hook = proc {}
        described_class.after_events(&hook)
        expect(described_class.after_events).to eq([described_class::DEFAULT_HOOK, hook])
      end
    end

    context 'when a hook is not registered' do
      it 'returns the default hook' do
        expect(described_class.after_events).to eq([described_class::DEFAULT_HOOK])
      end
    end
  end

  describe '.before_events' do
    context 'when a is hook registered' do
      it 'returns that hook' do
        hook = proc {}
        described_class.before_events(&hook)
        expect(described_class.before_events).to eq([described_class::DEFAULT_HOOK, hook])
      end
    end

    context 'when a hook is not registered' do
      it 'returns the default hook' do
        expect(described_class.before_events).to eq([described_class::DEFAULT_HOOK])
      end
    end
  end

  describe '.inherited' do
    it 'copies before hooks on to the inheritor' do
      before_hook = proc {}
      described_class.before_events(&before_hook)
      sub_class = Class.new(described_class)
      expect(sub_class.before_events).to include(before_hook)
    end

    it 'copies after hooks on to the inheritor' do
      after_hook = proc {}
      described_class.after_events(&after_hook)
      sub_class = Class.new(described_class)
      expect(sub_class.after_events).to include(after_hook)
    end

    context 'when subclasses define their own elements' do
      it 'puts the element definition on the sub class' do
        custom_element = Class.new(described_class) do
          text_field :form_field, id: 'field_id'
        end
        expect(custom_element.new(:page_element).element_definitions).to include(:form_field)
      end

      it 'does not put the definition on the parent class' do
        Class.new(described_class) do
          text_field :form_field, id: 'field_id'
        end
        expect(described_class.new(:page_element).element_definitions).not_to include(:form_field)
      end
    end
  end

  describe '.load' do
    let(:page_source) do
      <<-HTML
          <div id='links'>
            <a class='cta'>link text</a>
          </div>
      HTML
    end

    it 'returns an instance that works against the supplied string' do
      subject = Class.new(described_class) do
        element(:links, id: 'links') { link(:cta, css: '.cta') }
      end
      expect(subject.load(page_source).links.cta.text).to eq('link text')
    end
  end

  describe '.watch' do
    it 'adds a before hook' do
      watch_block = described_class.watch(:object_id).last
      expect(described_class.before_events).to include(watch_block)
    end

    describe 'the before hook that is added' do
      it 'contains a watcher' do
        watch_block = described_class.watch(:object_id).last
        instance = described_class.new(:element)
        instance.instance_exec(&watch_block)

        watcher = instance.watchers.first
        expect(watcher.observed_value).to eq(instance.object_id)
      end
    end
  end

  describe 'EVENT_TYPES' do
    it 'creates methods for each of the event types' do
      instance = described_class.new(:capybara_element)
      missing = described_class::EVENT_TYPES.find_all { |event| !instance.respond_to?(event) }
      expect(missing).to be_empty
    end

    context 'when one of the methods are called' do
      it 'calls the browser_element passing on all args' do
        browser_element = instance_double(Capybara::Node::Actions)
        allow(browser_element).to receive(:select)
        described_class.new(browser_element).select :args
        expect(browser_element).to have_received(:select).with(:args)
      end
    end

    context 'when the underlying capybara element does not respond to the method' do
      it 'raises an error' do
        expected_message = (described_class::EVENT_NOT_SUPPORTED_MSG % 'click')
        browser_element = instance_double(Capybara::Node::Element)
        page_element = described_class.new(browser_element)
        expect { page_element.click }.to raise_error(PageMagic::NotSupportedException, expected_message)
      end
    end
  end

  describe 'hooks' do
    context 'when a method called from within a before_events hook' do
      let(:page_element_class) do
        Class.new(described_class) do
          before_events do
            call_in_before_events
          end
        end
      end

      it 'delegates to the `PageMagic::Element`' do
        capybara_button = instance_double(Capybara::Node::Element, click: true)
        page_element = page_element_class.new(capybara_button)
        allow(page_element).to receive(:call_in_before_events)
        page_element.click
        expect(page_element).to have_received(:call_in_before_events)
      end
    end

    context 'when a method called from within a after_events hook' do
      let(:page_element_class) do
        Class.new(described_class) do
          after_events do
            call_in_after_events
          end
        end
      end

      it 'delegates to the `PageMagic::Element`' do
        capybara_button = instance_double(Capybara::Node::Element, click: true)
        page_element = page_element_class.new(capybara_button)
        allow(page_element).to receive(:call_in_after_events)
        page_element.click
        expect(page_element).to have_received(:call_in_after_events)
      end
    end
  end

  describe '#initialize' do
    it 'sets the parent element' do
      described_class.parent_element(:page)
      instance = described_class.new(:element)
      expect(instance.parent_element).to eq(:page)
    end

    describe 'inherited items' do
      it 'copies the before hooks' do
        before_hook = proc {}
        described_class.before_events(&before_hook)

        instance = described_class.new(:element)
        expect(instance.before_events).to include(before_hook)
      end

      it 'copies the after hooks' do
        after_hook = proc {}
        described_class.after_events(&after_hook)

        instance = described_class.new(:element)
        expect(instance.after_events).to include(after_hook)
      end
    end
  end

  describe '#method_missing' do
    context 'when no sub element definition found' do
      it 'delegates to the capybara element' do
        instance = described_class.new(instance_double(Capybara::Node::Element, visible?: true))
        expect(instance).to be_visible
      end
    end

    context 'when method not found on the capybara element' do
      it 'calls method on parent element' do
        element = Struct.new(:parent_method).new(:called)
        described_class.parent_element(element)
        instance = described_class.new(:capybara_element)
        expect(instance.parent_method).to eq(:called)
      end
    end

    context 'when the method is not found on parent' do
      it 'throws and exception' do
        described_class.parent_element(:parent_element)
        instance = described_class.new(:capybara_element)
        expect { instance.bobbins }.to raise_exception NoMethodError
      end
    end
  end

  describe '#respond_to?' do
    subject(:instance) do
      capybara_element = Struct.new(:element_method).new(:called)
      Class.new(described_class) do
        element :sub_element, css: '.sub-element'
      end.new(capybara_element)
    end

    it 'checks for methods on self' do
      expect(instance).to respond_to(:session)
    end

    it 'checks against registered elements' do
      expect(instance).to respond_to(:sub_element)
    end

    it 'checks for the method of the browser_element' do
      expect(instance).to respond_to(:element_method)
    end
  end

  describe '#session' do
    it 'has a handle to the session' do
      described_class.parent_element(instance_double(PageMagic::InstanceMethods, session: :session))
      instance = described_class.new(:capybara_element)
      expect(instance.session).to eq(:session)
    end
  end
end
