# frozen_string_literal: true

Dir["#{__dir__}/shared_contexts/*.rb"].sort.each do |file|
  require file
end
