[![Circle CI](https://circleci.com/gh/Ladtech/page_magic.svg?style=shield&circle-token=49c8f6869c1e0dc6f3b368e6e22a11fcea3aab8a)](https://circleci.com/gh/Ladtech/page_magic) [![Code Climate](https://codeclimate.com/github/Ladtech/page_magic/badges/gpa.svg)](https://codeclimate.com/github/Ladtech/page_magic) [![Test Coverage](https://codeclimate.com/github/Ladtech/page_magic/badges/coverage.svg)](https://codeclimate.com/github/Ladtech/page_magic/coverage) [![PullReview stats](https://www.pullreview.com/github/Ladtech/page_magic/badges/master.svg?)](https://www.pullreview.com/github/Ladtech/page_magic/reviews/master)
#PageMagic
PageMagic is an API for testing web applications. 

It has a simple but powerful DSL which makes modelling and interacting with your pages easy.

Wouldn't it be great if there was a framework that could:
- [Model your pages](#defining-pages)
- [Fluently define event hooks / waiters on page elements](#hooks)
- [Map paths to pages so that the correct page object is loaded as you navigate](#page-mapping)
- [Be super dynamic](#dynamic-selectors)

Well PageMagic might just be the answer!

Give it a try and let us know what you think! There will undoubtedly be things that can be improved and issues that we are not aware of so your feedback/pull requests are greatly appreciated!
# Contents
- [Installation](#installation)
- [Starting a session](#starting-a-session)
- [Defining Pages](#defining-pages)
  - [Elements](#elements)
  - [Hooks](#hooks)
    - [Element event hooks](#element-event-hooks)
    - [On load hook](#on-load-hook)
  - [Helper Methods](#helper-methods)
  - [Sub Elements](#sub-elements)
  - [Dynamic Selectors](#dynamic-selectors)
- [Watchers](#watchers)
  - [Method watchers](#method-watchers)
  - [Simple watchers](#simple-watchers)
  - [Custom watchers](#custom-watchers)
- [Page mapping](#page-mapping)
- [Drivers](#drivers)
- [Pulling it all together](#pulling-it-all-together)

# Installation
`gem install page_magic --pre`

# Starting a session
To start a PageMagic session simply decide what browser you want to use and pass it to PageMagic's `.session` method
```ruby
session = PageMagic.session(browser: :chrome, url: 'https://21st-century-mail.com')
```
Out of the box, PageMagic knows how to work with:
- Chrome and Firefox
- poltergeist
- RackTest - Read more on testing rack compliant object's directly later on

Under the hood, PageMagic is using [Capybara](https://github.com/jnicklas/capybara) so you can register any Capybara specific driver you want. See [below](#registering-a-custom-driver) for how to do this.

**Note:** We don't want to impose particular driver versions so PageMagic does not list any as dependencies. Therefore you will need add the requiste gem to your Gemfile.

# Defining Pages
To define something that PageMagic can work with, simply include PageMagic in to a class.
```ruby
class LoginPage
  include PageMagic
end
```
## Elements
Defining elements is easy see the example below.

```ruby
class LoginPage
  include PageMagic
  text_field(:username, label: 'username')
  text_field(:password, label: 'password')
  button(:login_button, text: 'login')
end
```

### Interacting with elements
Elements are defined with an id which is the name of the method you will use to reference it. In the above example, the textfields and button were defined with the id's, `:username`, `:password`, and `:login_button`

After visiting a page with a PageMagic session, you can access all of the elements of that page through the session itself.
```ruby
session.username.set 'joe@blogs.com'
session.password.set 'passw0rd'
session.login_button.click
```

## Hooks
PageMagic provides hooks to allow you to interact at the right moments with your pages

### On Load hook
PageMagic lets you define an on_load hook for your pages. This lets you write any custom wait logic you might need 
before letting execution continue.
```ruby
class LoginPage
  # ... code defining elements as shown above
  
  on_load do
    # wait code here
  end
end
```

### Element event hooks
Frequently, you are going to have to work with pages that make heavy use of ajax. This means that just because you've clicked something, it doesn't mean that the action is finished. For these occasions PageMagic provides `before_events` and `after_events` hooks that you use to perform custom actions and wait for things to happen.

```ruby
class MessagePage
  include PageMagic
  ## code defining other elements, such as subject and body
  
  link(:delete id: 'delete-message') do
    after_events do
      wait_until{fancy_animation_has_disappeared?}
    end
  end
end
```

## Helper methods
Using elements that are defined on a page is great, but if you are enacting a procedure through interacting with a few of them then your code could end up with some pretty repetitive code. In this case you can define helper methods instead. 

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

We can interact with helper in the same way as we did page elements.
```ruby
session.login('joe', 'blogs')
```

##Sub Elements
If your pages are complex you can use PageMagic to compose pages, their elements and subelements to as many levels as you need to.

```ruby
class MailBox
  include PageMagic
  
  element :message, id: 'message_id' do
    link(:read, text: 'read')
  end
end
```
Sub elements can be accessed through their parent elements e.g:
```
session.message.read.click
```
## Dynamic Selectors
In some cases you will able to specify the selector for an element until runtime. PageMagic allows you to handle such situations with support for dynamic selectors.

```ruby
class MailBox
  include PageMagic
  
  element :message do |subject:|
    selector xpath: '//tr[text()="#{subject}"]' 
    link(:read, text: 'read')
  end
end
```
Here we have defined the 'message' element using a block that takes subject argument. This is passed in at run time and given to the xpath selector.
```ruby
session.message(subject: 'test message')
```

# Watchers
PageMagic lets you set a watcher on any of the elements that you have defined on your pages. Use watchers to decide when
things have changed. 

**Note**: Watchers are not inherited

## Method watchers
Method watchers watch the output of the given method name.
```ruby
button :javascript_button, css: '.fancy_button' do
  before_events do
    watch(:url)
  end
  
  after_events do
    wait_until{changed?(:url)}
  end
end
```

## Simple watchers
Simple watchers use the `watch` method passing two parameters, the first is the name of the element you want to keep an 
eye and the second is the method that needs to be called to get the value that should be observed.
```ruby
element :product_row, css '.cta' do
  before_events do
    element(:total, css: '.total')
  end
  
  after_events do
    wait_until{changed?(:total)}
  end
end
```
## Custom watchers
Custom watchers are defined by passing a name and block parameter to the `watch` method. The block returns the value 
that needs to be observed. Use watch in this way if you need to do something non standard to obtain a value or to 
access an element not located within the current element but elsewhere within the page.
```ruby
element :product_row, css '.cta' do
  before_events do
    element(:total) do
      session.nav.total.text
    end
  end
  
  after_events do
    wait_until{changed?(:total)}
  end
end
```
# Page mapping
With PageMagic you can map which pages should be used to handle which URL paths. This is a pretty killer feature that will remove a lot of the juggling and bring back fluency to your code!
```ruby
# define what pages map to what
browser.define_page_mappings %r{/messages/\d+} => MessagePage,
                             '/login' => LoginPage,
                             '/' => MailBox
```
You can use even use regular expressions to map multiple paths to the same page. In the above example we are mapping paths that that starts with '/messages/' and are followed by one ore more digits to the `MessagePage` class.

# Drivers
## Registering a custom driver
You can register any Capybara compliant driver as follows

```ruby
#1. Define driver, constructor to PageMagic::Driver takes a list of browser aliases.
# Selenium Webdriver for example supports driving more than one.
Webkit = PageMagic::Driver.new(:webkit) do |app, options, browser_alias_chosen|
  # Write the code necessary to initialise the driver you have chosen
  require 'capybara/webkit'
  Capybara::Webkit::Driver.new(app, options)
end

#2. Register driver
PageMagic.drivers.register Webkit

#3. Use registered driver
session = PageMagic.session(browser: webkit, url: 'https://21st-century-mail.com')
```

# Pulling it all together
Imagine the scene. You've written a web based mail client and now you want to test it...
You have a scenario in mind that goes something along the lines of:
- Send yourself an email with a unique subject
- Go to the Login page and login
- Find the message using it's unique subject and read it
- delete the message

You're mail client is totally 21st century so there is loads of lovely ajax etc...

Using the PageMagic you can implement an API that might look something like the following to use:

```ruby
test_subject = send_test_mail('test@21st-century-mail.com')
#Visit your site using a PageMagic session we prepared earlier
session.visit(LoginPage)

#Login using some handy helper method on our page object
session.login('username', 'password')

#Find the message amongst all the other messages that are on screen and read it
session.message(subject: test_subject).read.click

#Now we are on the message screen lets delete it without having to worry about the ajax.
session.delete_message

fail "message is still there!" if session.message(subject: test_subject).exists?

# Sweet :)
```
