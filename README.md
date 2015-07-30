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
#Visit your site using a PageMagic session we prepared earlier
session.visit(LoginPage, url: 'https://21st-century-mail.com')

#Login using some handy helper method on our page object
session.login('username', 'password')

#Find the message amongst all the other messages that are on screen and read it
session.message(subject: test_subject).read.click

#Now we are on the message screen lets delete it without having to worry about the ajax.
session.delete_message

fail "message is still there!" if session.message(subject: test_subject).exists?

# Sweet :)
```
## Starting a session
To start a PageMagic session simply decide what browser you want to use and pass it to PageMagic's `.session` method
```ruby
session = PageMagic.session(browser: :chrome)
```
Out of the box, PageMagic has knows how to work with:
- Chrome and Firefox
- poltergeist
- rack_test - Read more on testing rack compliant object's directly later on

Under the hood, PageMagic is using [Capybara](https://github.com/jnicklas/capybara) so you can register capybara specific driver you want and use it. See below for how to do this.

**Note:** We don't want to impose a particular driver so PageMagic does not list any as dependencies. Therefore you will need add the requiste gem to your Gemfile.

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
```ruby
session.visit(LoginPage, url: 'https://21st-century-mail.com')
```
soon you won't even have to specify the page class :)

##Defining elements
Your pages are going to have elements on them that you will want to interact with. In the case of the Login page, it's easy to imagine that it will have text fields for a username and password and a button to login in with.
```ruby
class LoginPage
  include PageMagic
  text_field(:username, label: 'username')
  text_field(:password, label: 'password')
  button(:login_button, text: 'login')
end
```
##Interacting with elements
after visiting a page with a PageMagic session, you can access all of the elements of that page through the session itself.
```ruby
session.username.set 'joe@blogs.com'
session.password.set 'passw0rd'
session.login_button.click
```
##Defining helper methods
Using elements that are defined on a page is great, but if you are enacting some procedure using a few of them then you could end up with some pretty repetitive code. In this case you could define a helper method instead. In the above example we used a `login` helper.
```ruby
class LoginPage
  # ... code defining elements as shown above
  
  def login(user, pass)
    username.set user
    password.set pass
    login_button.click
  end
end
```
##Defining sub elements
Your page may be a complex one and elements that you want to work with maybe inside other widgets. With PageMagic you can compose your pages their elements and subelements to as many levels as you need to.

In the above example we accessed a read link that resided with a particular message
```ruby
class MailBox
  include PageMagic
  
  element :message, id: 'message_id' do
    link(:read, text: 'read')
  end
end

#here we can access the read link through the message
session.message.read.click
```
## Dynamic Selectors
In our scenario we actually selected a message based on a subject that was randomly generated. In this case we would not be able to hard code the selector for our message but instead would need to set the selector dynamically.

```ruby
class MailBox
  include PageMagic
  
  element :message do |subject:|
    selector xpath: '//tr[text()="#{subject}"]'
    link(:read, text: 'read')
  end
end
```
In the above example we have defined the 'message' element using a block that takes subject argument. This is passed in at run time and given to the xpath selector.
```ruby
session.message(subject: 'test message')
```
## Interaction hooks

```ruby

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


