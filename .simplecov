require 'pullreview/coverage'
require "codeclimate-test-reporter"

SimpleCov.formatters  = [SimpleCov::Formatter::HTMLFormatter,PullReview::Coverage::Formatter,CodeClimate::TestReporter::Formatter]

SimpleCov.start do
  add_filter '/spec/'
end