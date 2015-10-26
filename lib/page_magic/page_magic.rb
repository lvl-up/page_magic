module PageMagic
  attr_reader :browser, :session, :browser_element

  def initialize(session = Session.new(Capybara.current_session), &block)
    @browser = session.raw_session
    @session = session

    @browser_element = browser
    block.call browser if block
  end

  def title
    browser.title
  end

  def text_on_page?(string)
    text.downcase.include?(string.downcase)
  end

  def visit
    browser.visit self.class.url
    self
  end

  def text
    browser.text
  end

  def method_missing(method, *args)
    element_context.send(method, *args)
  end

  def respond_to?(*args)
    super || element_context.respond_to?(*args)
  end

  def element_context
    ElementContext.new(self, self)
  end
end
