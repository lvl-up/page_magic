module PageMagic
  class Drivers
    Poltergeist = Driver.new(:poltergeist) do |app, options|
      require 'capybara/poltergeist'
      Capybara::Poltergeist::Driver.new(app, options)
    end
  end
end
