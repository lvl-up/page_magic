# frozen_string_literal: true

RSpec.shared_context 'files' do
  require 'tmpdir'

  def scratch_dir
    @scratch_dir ||= Dir.mktmpdir
  end
end
