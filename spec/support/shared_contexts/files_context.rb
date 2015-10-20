shared_context :files do
  require 'tmpdir'

  def scratch_dir
    @dir ||= Dir.mktmpdir
  end
end
