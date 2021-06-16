# frozen_string_literal: true

this_dir = File.dirname(__FILE__)
$LOAD_PATH.unshift("#{this_dir}/lib")
require 'support/shared_contexts'
require 'support/shared_examples'

require 'simplecov' if ENV['coverage']

require 'page_magic'

Dir["#{this_dir}/../lib/page_magic/drivers/*.rb"].each do |driver|
  require driver
end
Capybara.server = :webrick
