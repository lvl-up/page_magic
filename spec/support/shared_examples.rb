# frozen_string_literal: true

RSpec.shared_examples 'session accessor' do
  it 'includes session methods' do
    expect(described_class.included_modules).to include(PageMagic::SessionMethods)
  end
end

RSpec.shared_examples 'element watcher' do
  it 'includes watchers' do
    expect(described_class.included_modules).to include(PageMagic::Watchers)
  end
end

RSpec.shared_examples 'waiter' do
  it 'includes waiters' do
    expect(described_class.included_modules).to include(PageMagic::WaitMethods)
  end
end

RSpec.shared_examples 'element locator' do
  it 'includes Locators' do
    expect(described_class.included_modules).to include(PageMagic::Element::Locators)
  end
end
