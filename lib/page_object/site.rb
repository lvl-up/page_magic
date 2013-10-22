module PageObject
  class Site
    class << self
      def visit options = {}

        if browser = options[:browser]
          Capybara.register_driver browser do |app|
            Capybara::Selenium::Driver.new(app, options)
          end
          Session.new(Capybara::Session.new(browser,nil))
        else
          Capybara.reset!
          Session.new(Capybara.current_session)
        end

      end
    end
  end
end