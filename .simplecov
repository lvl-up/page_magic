require 'pullreview/coverage'

SimpleCov.formatters  = [SimpleCov::Formatter::HTMLFormatter,PullReview::Coverage::Formatter]

SimpleCov.start do
  add_filter '/spec/'
end