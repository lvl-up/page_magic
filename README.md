#PageMagic
PageMagic is an API for testing web applications. 

It has a simple but powerful DSL which makes modelling and interacting with your pages easy.

So... Wouldn't it be great if you could write some page objects that:
- Modelled your pages
- Define custom wait activity that should occur before or after you interact with a page element at the point the element is defined
- Map the paths that pages map to so, that when you transition from one page to another, you don't have to do awkward things to work out which page object you need to use next?
- Were really dynamic so that you could do even more things at runtime?

Well PageMagic might just be the answer!

Imagine the scene. You've written a we based mail client and now you want to test it...
You have a scenario in mind that goes something along the lines of:
- Send yourself an email with a unique subject
- Go to the Login page and login
- Find the message using it's unique subject and read it
- delete the message

You're mail client is total 21st century so there is loads of lovely ajax etc...

Writing robust, nice looking code for this could be a real pain... 
Here's how you might do it with PageMagic (note that the following code would work if we you had a compatible mail web app but in this case is purely illustrative)

What we really want to write is something like
```ruby
test_subject = send_test_mail('test@21st-century-mail.com')
#Visit your site
browser.visit(LoginPage, url: 'https://21st-century-mail.com')

#Login using some handy helper method on our page object
browser.login('username', 'password')

#Find the message amongst all the other messages that are on screen and read it
browser.message(subject: test_subject).read.click

#Now we are on the message screen lets delete it without having to worry about the ajax.
browser.delete_message

fail "message is still there!" if browser.message(subject: test_subject).exists?

# Sweet :)
```
## Starting a session
To start a PageMagic session simply decide what browser you want to use and pass it to PageMagic's `.session` method
```ruby
browser = PageMagic.session(browser: :chrome)
```
Out of the box, PageMagic has knows how to work 
Under the hood, PageMagic is using [Capybara](https://github.com/jnicklas/capybara) so you can register capybara specific driver you want and use it. See below for how to do this.

## Defining Pages
To define something that PageMagic can work with simply include PageMagic in to a class. Here are the classes we would need for the example above.
```ruby
class LoginPage
  include PageMagic
end

class MailBox
  include PageMagic
end

class MessageView
  include PageMagic
end
```

##Visiting a page
To use a page ojbect you need to 'visit' it.
ruby
```

##Defining elements
Your pages are going to have elements on them that you will want to interact with. In the case of the Login page, it's easy to imagine that it will have text fields for a username and password and a button to login in with.
```ruby
class LoginPage
  include PageMagic
  text_field(:username, label: 'username')
  text_field(:password, label: 'password')
  button(:login, text: 'login')
end
```
##Defining helper methods
Using the Login page above

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
  
  element :message do |subject:|
    selector xpath: '//tr[text()="#{subject}"]'
    link(:read, text: 'read')
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
browser.messages.message(5).read
browser.message(5).delete
```


