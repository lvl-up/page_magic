# frozen_string_literal: true

RSpec.describe PageMagic::WaitMethods do
  include described_class

  describe '#wait_until' do
    let(:default_options) { { timeout_after: 0.1, retry_every: 0.05 } }
    let!(:start_time) { Time.now }

    it 'waits until the prescribed thing has happened' do
      expect { wait_until(**default_options) { true } }.not_to raise_exception
    end

    it 'keeps trying for a specified period' do
      wait_until(**default_options) { false }
    rescue PageMagic::TimeoutException
      expect(Time.now - default_options[:timeout_after]).to be > start_time
    end

    context 'when `timeout_after` specified' do
      it 'throws an exception if when the prescribed action does not happen in time' do
        expect { wait_until(**default_options) { false } }.to raise_error PageMagic::TimeoutException
      end
    end

    context 'when retry time specified' do
      it 'retries at the given interval' do
        count = 0
        expect { wait_until(timeout_after: 0.2, retry_every: 0.1) { count += 1 } }
          .to raise_exception(PageMagic::TimeoutException)
          .and change { count }.by(2)
      end
    end
  end
end
