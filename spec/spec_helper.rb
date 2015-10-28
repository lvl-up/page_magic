Bundler.require
$LOAD_PATH.unshift("#{File.dirname(__FILE__)}/lib")

require 'support/shared_contexts'

if ENV['coverage']
  # require "codeclimate-test-reporter"
  require 'simplecov'
  # CodeClimate::TestReporter.start
end

require 'page_magic'
