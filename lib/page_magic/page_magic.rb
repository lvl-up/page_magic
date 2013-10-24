module PageMagic
  attr_reader :browser
  include AjaxSupport

  def initialize session=Capybara.current_session, options={}, &block
    if session.is_a? Capybara::Session
      @browser = session
    else
      @browser = session.browser
      @session = session
    end
    navigate if options[:navigate_to_page]
    block.call @browser if block
  end

  def move_to page_class
    page_class = eval(page_class) if page_class.is_a?(String)
    @session.current_page = page_class.new @session
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

  def visit
    @browser.visit self.class.url
    self
  end

  def click text
    self.send(text.downcase.gsub(" ", "_").to_sym)
  end

  def text
    @browser.text
  end

  def text_on_page? text
    begin
      @browser.text.force_encoding("ISO-8859-1").encode("utf-8", :replace => nil).downcase.include?(text.downcase)
    rescue Selenium::WebDriver::Error::NoSuchElementError
      return false
    end
  end

  def text_on_window? title, text
    exists = false
    @browser.window(:title => title).use do
      exists = @browser.text.downcase.include?(text.downcase)
    end
    exists
  end

  def window_exists? title
    @browser.window(:title => title).exists?
  end

  def accept_popup
    swith_to_alert.accept
  end

  def alert_present?
    begin
      swith_to_alert
      return true
    rescue Selenium::WebDriver::Error::NoAlertPresentError
      return false
    end
  end

  def text_in_popup? text
    popup_text.include?(text.downcase)
  end

  def enter page_element, value
    self.send(page_element, value)
  end

  #TODO - consolidate this
  def method_missing method, *args
    ElementContext.new(self, @browser, self, *args).send(method, args.first)
  end

  private
  def popup_text
    @browser.driver.switch_to.alert.text.downcase
  end

  def swith_to_alert
    @browser.driver.switch_to.alert
  end
end




