require 'pullreview/coverage'

SimpleCov.formatters  = [SimpleCov::Formatter::HTMLFormatter,PullReview::Coverage::Formatter]

SimpleCov.start do
  add_filter '/spec/'
  add_filter '/lib/active_support/core_ext/object/to_query.rb'
end