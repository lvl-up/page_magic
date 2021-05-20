# frozen_string_literal: true

RSpec.shared_context 'rack application' do
  let(:rack_application) do
    Class.new do
      def call(_env)
        [200, {}, ['hello world!!']]
      end
    end
  end
end
