# frozen_string_literal: true

require 'date'
require_relative 'lib/page_magic/version'
Gem::Specification.new do |s|
  s.name = "page_magic"
  s.version = PageMagic::VERSION
  s.authors = ["Leon Davis"]
  s.date = Date.today
  s.description = "Framework for modeling and interacting with webpages which wraps capybara"
  s.email = "info@lvl-up.uk"
  s.extra_rdoc_files = [
    "README.md"
  ]
  s.files = Dir['lib/**/*.rb', 'README.md', 'VERSION', '.yardopts']
  s.homepage = "https://github.com/lvl-up/page_magic"
  s.licenses = ["Ruby"]
  s.required_ruby_version = Gem::Requirement.new(">= 2.5")
  s.summary = "Framework for modeling and interacting with webpages"

  s.add_runtime_dependency(%q<activesupport>.freeze, [">= 6"])
  s.add_runtime_dependency(%q<capybara>.freeze, ['~> 3'])
  s.add_development_dependency(%q<gem-release>.freeze, ['~> 2'])
  s.add_development_dependency(%q<poltergeist>.freeze, ['~> 1'])
  s.add_development_dependency(%q<rake>.freeze, ["~> 13"])
  s.add_development_dependency(%q<redcarpet>.freeze, ["~> 3"])
  s.add_development_dependency(%q<rspec>.freeze, ["~> 3"])
  s.add_development_dependency(%q<rubocop>.freeze, ["~> 1"])
  s.add_development_dependency(%q<rubocop-rspec>.freeze, ["~> 2"])
  s.add_development_dependency(%q<selenium-webdriver>.freeze, ['~> 3'])
  s.add_development_dependency(%q<simplecov>.freeze, ["~> 0"])
  s.add_development_dependency(%q<yard>.freeze, ["~> 0"])
  s.add_development_dependency(%q<debug>.freeze, ["~> 0"])
  s.add_development_dependency(%q<rackup>.freeze, ["~> 2"])
end
