Bundler.require
$LOAD_PATH.unshift("#{File.dirname(__FILE__)}/lib")

require 'support/shared_contexts'

require 'simplecov' if ENV['coverage']

require 'page_magic'
