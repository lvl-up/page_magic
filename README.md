#PageMagic
PageMagic is an API for testing web applications. 

It has a simple but powerful DSL which makes modelling and interacting with your pages easy.

So... Wouldn't it be great if you could write some page objects that:
- Modelled your pages
- Define custom wait activity that should occur before or after you interact with a page element at the point the element is defined
- Map the paths that pages map to so, that when you transition from one page to another, you don't have to do awkward things to work out which page object you need to use next?
- Were really dynamic so that you could do even more things at runtime?

Well PageMagic might just be the answer! Here's an example of the sort of thing you could write.
```ruby
# Define some pages
class LoginPage
  include PageMagic
  
  element(:google, '.google') do
    link(:login, css: '.login-button')
  end
end

class MailBox
  include PageMagic
  
  element(:messages, '.messages') do
    element :message do |subject:|
      selector xpath: '//a[text()=#{subject}]
      link(:read, text: 'read')
    end
  end
end

class MessagePage
  include PageMagic
  element(:subject, '.subject')
  element(:body, '.body')
  link(:delete, id: 'delete-message') do
    after do
      wait_until #some fancy animation has happened
    end
  end
  
  def delete
    #Code to click the link and accept the 'are you sure confirmation'
  end
end

# Create a session
browser = PageMagic.session(browser: :chrome)

# define what pages map to what
browser.define_page_mappings %r{/messages/\d+} => MessagePage,
                             '/login' => LoginPage
                             '/' => MailBox
                             
#Visit your site
browser.visit(LoginPage, url: 'https://theapp.com/login')
#start browsing :)
browser.via_google.login.click
browser.messages(5).read.click
browser.message(5).delete
```


