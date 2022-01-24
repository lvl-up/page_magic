# frozen_string_literal: true

Bundler.require :test, :development

require 'rubocop/rake_task'
require 'rspec/core/rake_task'

RuboCop::RakeTask.new

RSpec::Core::RakeTask.new(:spec) do
  ENV['coverage'] = 'true'
end

require 'rake/testtask'
Rake::TestTask.new do |t|
  t.libs << 'spec'
  t.pattern = 'spec/**/*_test.rb'
  t.warning = true
  t.verbose = true
end

task default: [:spec, :test, 'rubocop:auto_correct']
