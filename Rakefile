require 'rspec/core/rake_task'
RSpec::Core::RakeTask.new(:spec) do
  ENV['coverage'] = "true"
end

task :default => :spec