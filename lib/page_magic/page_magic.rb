module PageMagic
  attr_reader :browser, :session

  def initialize session=Session.new(Capybara.current_session), options={}, &block

    @browser = session.raw_session
    @session = session

    @browser_element = @browser
    navigate if options[:navigate_to_page]
    block.call @browser if block
  end

  def title
    @browser.title
  end

  def text_on_page? text
    text().downcase.include?(text.downcase)
  end

  def visit
    @browser.visit self.class.url
    self
  end

  def text
    @browser.text
  end

  def method_missing method, *args
    element_context.send(method, *args)
  end

  def respond_to? *args
    super || element_context.respond_to?(*args)

  end

  def element_context
    ElementContext.new(self, @browser, self)
  end
end




