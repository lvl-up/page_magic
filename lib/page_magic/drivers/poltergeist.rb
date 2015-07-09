module PageMagic
  class Drivers
    Poltergeist = Driver.new(:poltergeist) do
      require 'capybara/poltergeist'
      Capybara::Poltergeist::Driver
    end
  end

end