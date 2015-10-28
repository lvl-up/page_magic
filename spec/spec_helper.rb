Bundler.require
$LOAD_PATH.unshift("#{File.dirname(__FILE__)}/lib")

if ENV['coverage']
  require "codeclimate-test-reporter"
  require 'simplecov'
  CodeClimate::TestReporter.start
end

require 'page_magic'
require 'capybara/rspec'
require 'helpers/capybara'

require 'page_magic'
