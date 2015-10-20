Bundler.require
$LOAD_PATH.unshift(__dir__, "#{__dir__}/../lib")

require 'support/shared_contexts'
require 'simplecov' if ENV['coverage']

require 'page_magic'
