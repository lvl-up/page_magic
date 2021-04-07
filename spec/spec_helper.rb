# frozen_string_literal: true
require 'bundler'
Bundler.require
$LOAD_PATH.unshift("#{File.dirname(__FILE__)}/lib")
require 'support/shared_contexts'
require 'support/shared_examples'

require 'simplecov' if ENV['coverage']

require 'page_magic'
Capybara.server = :webrick
