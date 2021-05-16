# frozen_string_literal: true

module PageMagic
  shared_examples 'session accessor' do
    it 'includes session methods' do
      expect(described_class.included_modules).to include(SessionMethods)
    end
  end

  shared_examples 'element watcher' do
    it 'includes watchers' do
      expect(described_class.included_modules).to include(Watchers)
    end
  end

  shared_examples 'waiter' do
    it 'includes waiters' do
      expect(described_class.included_modules).to include(WaitMethods)
    end
  end

  shared_examples 'element locator' do
    it 'includes Locators' do
      expect(described_class.included_modules).to include(Element::Locators)
    end
  end
end
