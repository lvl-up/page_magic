module PageMagic
  attr_reader :browser, :session

  include AjaxSupport

  def initialize session=Capybara.current_session, options={}, &block
    if session.is_a? Capybara::Session
      @browser = session
    else
      @browser = session.browser
      @session = session
    end
    @browser_element = @browser
    navigate if options[:navigate_to_page]
    block.call @browser if block
  end

  def title
    @browser.title
  end

  def refresh
    @browser.refresh
  end

  def current_path
    @browser.current_path
  end

  def text_on_page? text
    text().downcase.include?(text.downcase)
  end

  def window_exists? title
    raise "implement me"
  end

  def accept_popup
    raise "implement me"
  end

  def alert_present?
    raise "implement me"
  end

  def text_in_popup? text
    raise "implement me"
  end

  def visit
    @browser.visit self.class.url
    self
  end

  def click element
    self.send(element.downcase.gsub(" ", "_").to_sym)
  end

  def text
    @browser.text
  end

  def method_missing method, *args
    ElementContext.new(self, @browser, self).send(method, *args)
  end
end




