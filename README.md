[![Gem Version](https://badge.fury.io/rb/page_magic.svg)](https://badge.fury.io/rb/page_magic) 
[![Dependency Status](https://gemnasium.com/lvl-up/page_magic.svg)](https://gemnasium.com/Ladtech/page_magic) 
[![CircleCI](https://circleci.com/gh/lvl-up/page_magic.svg?style=shield&circle-token=49c8f6869c1e0dc6f3b368e6e22a11fcea3aab8a)](https://circleci.com/gh/lvl-up/page_magic)
[![Code Climate](https://codeclimate.com/github/Ladtech/page_magic/badges/gpa.svg)](https://codeclimate.com/github/Ladtech/page_magic)
[![Test Coverage](https://codeclimate.com/github/Ladtech/page_magic/badges/coverage.svg)](https://codeclimate.com/github/Ladtech/page_magic/coverage) 
[![PullReview stats](https://www.pullreview.com/github/lvl-up/page_magic/badges/master.svg?)](https://www.pullreview.com/github/lvl-up/page_magic/reviews/master)
#PageMagic
PageMagic is an API for testing web applications. 

It has a simple but powerful DSL which makes modelling and interacting with your pages easy.

Wouldn't it be great if there was a framework that could:

- [Model your pages](#defining-pages)
- [Fluently define event hooks / waiters on page elements](#hooks)
- [Map paths to pages so that the correct page object is loaded as you navigate](#page-mapping)
- [Be super dynamic](#dynamic-selectors)

Well PageMagic might just be the answer!

Give it a try and let us know what you think! There will undoubtedly be things that can be improved and issues that 
we are not aware of so your feedback/pull requests are greatly appreciated!

##Under the hood
Under the hood PageMagic uses the totally brilliant [Capybara](https://github.com/teamcapybara/capybara) to benefit from its amazing cross browser support.
 
PageMagic builds on top of Capybara to build resuable models for webpages and website structure.
 
##What about the other PageObject frameworks out there?
PageMagic isn't the first [PageObject](https://martinfowler.com/bliki/PageObject.html) framework to be written, indeed there are others out there that are totaly awesome e.g:
- [PageObject](https://github.com/cheezy/page-object)
- [SitePrism](https://github.com/natritmeyer/site_prism)

Whilst these APIs are great, PageMagic goes much further in the power it provides for:
 - [modelling pages](defining-pages) and page components 
 - defining the [wait logic](#hooks) and [watchers](#watchers) that are required to build robust page objects that work reliably with javascript rich webpages.
 - Supporting [page transitions](#page-mapping)
 
Check it out :)

 
# Contents

- [Installation](#installation)
- [Quick Start](#quick-start)
- [Defining Pages](#defining-pages)
  - [Elements](#elements)
    - [Singlular Results](#singular-results)
    - [Multiple Results](#multiple-results)
    - [Interacting with elements](#interacting-with-elements)
    - [Sub elements](#sub-elements)
    - [Custom elements](#custom-elements)
  - [Hooks](#hooks)
    - [Element event hooks](#element-event-hooks)
    - [On load hook](#on-load-hook)
  - [Helper Methods](#helper-methods)
  - [Dynamic Selectors](#dynamic-selectors)
- [Starting a session](#starting-a-session)
- [Page mapping](#page-mapping)
  - [Mapping against query string parameters](#mapping-against-query-string-parameters)
  - [Mapping against fragment identifiers](#mapping-against-fragment-identifiers)
- [Loading pages from source](#loading-pages-from-source)
- [Watchers](#watchers)
  - [Method watchers](#method-watchers)
  - [Simple watchers](#simple-watchers)
  - [Custom watchers](#custom-watchers)
- [Waiting](#waiting)
- [Drivers](#drivers)
- [Cucumber Quick Start](#cucumber-quick-start)

# Installation
`gem install page_magic`

# Quick Start
Getting started with PageMagic is easy, try running this:

```ruby
require 'page_magic'

class Github
  include PageMagic
  
  url 'https://www.github.com'

  text_field :search_field, name: 'q' do
    watch(:url)
    
    after_events do
      wait_until { changed?(:url) }
    end
  end

  def search(project_name)
    search_field.set "#{project_name}\n"
  end
end
github = Github.visit(browser: :chrome)
github.search('page_magic')
```

This example defines a page to represent Github's home page, visits it and performs a search. 

This code models a single page and will let you [interact](#interacting-with-elements) with the [elements](#elements) 
defined on it as well as use the [helper method](Helpers) we defined.

You can do lots with PageMagic including [mapping pages](#page-mapping) to a [session](#starting-a-session) so that 
they are fluidly switched in for you. You can even define [hooks](#hooks) to run when ever a element is interacted 
with. So what are you wating for? there's no place better to start than the [beginning](#defining-pages). Have fun! :)

# Defining Pages
To define something that PageMagic can work with, simply include PageMagic in to a class.
```ruby
class Github
  include PageMagic
end
```
## Elements
Defining elements is easy. Just give the:
- element_type
- id to refer to it by
- selector to find it in the page

The following example defines a text field called 'search_field' that can be found using its name which is 'q'

```ruby
class Github
  include PageMagic
  
  text_field :search_field, name: 'q'
end
```

Element types supported by PageMagic are:
- text_field
- button
- link
- checkbox
- select_list
- radio
- textarea

PageMagic is very powerful and provides a number of different ways to define a page element so for more details please look at the [API](http://www.rubydoc.info/gems/page_magic/PageMagic%2FElements:element)

### Singular Results
The element types written above are the method names you need to use in order to define elements of those types on your pages.

Using them as they are written above will tell PageMagic to expect to find only one element using the selector you supply. Finding more than one result will cause PageMagic to raise an `AmbiguousQueryException` 

### Multiple Results
Applying an 's' to the end of the element definition method name will tell PageMagic that more than one result can be returned using the given selector.

results are returned in an `Array`.
```ruby
class ResultsPage
  include PageMagic
  elements :results, css: '.repo-list-item'
end

page.results #=> Array<Element> 
```


### Interacting with elements
```ruby
class Github
  include PageMagic
  
  text_field :search_field, name: 'q'
end
```
Elements are defined with an id which is the name of the method you will use to reference it. In the above example, 
the text field was defined with the id `:search_field`.

After visiting a page you are will get a `Session` object. Elements can be accessed through the session itself.

methods to set elements

 element    | method 
 ---        | --- 
 text_field | set
  

```ruby
page.search_field.set 'page_magic'
```
PageMagic sits on top of [Capybara](https://github.com/teamcapybara/capybara) and ultimately returns capybara elements elements for you interact with. Interacting with the element types above is done by calling the following methods:

 element     | method 
 ---         | --- 
 text_field  | set(String)
 checkbox    | set(Boolean)
 radio       | choose(String)
 link        | click
 text_area   | set(String)
 select_list | select(String)
 
Typically you will not need to know much about Capybara itself but there will be times when you want to interact with elements at a lower level.In this case please see Capybara's [API](http://www.rubydoc.info/github/jnicklas/capybara/Capybara/Node/Element) For more information.
 

### Sub Elements
If your pages are complex you can use PageMagic to compose pages, their elements and subelements to as many levels as 
you need to.

```ruby
class ResultsPage
  include PageMagic

  element :results, css: '.repo-list-item' do
    element :stats, css: '.repo-list-stats'
    element :meta_data, css: '.repo-list-meta'
    link :repo_link, css: 'h3 a'
  end
end
```

Sub elements can be accessed through their parent elements e.g:
```ruby
page.results.first.repo_link.click
```

### Custom elements
PageMagic allows you to define your own custom elements.
```ruby
class SearchField < PageMagic::Element
  selector name: 'q'
  # custom stuff
end

class Github 
  include PageMagic
  element SearchField
end
```

If an id is not specified then the name of the element class will be used. In the above example the name given to the element of type `SearchField` would be `search_field`. The selector for the element can bespecified on the class itself or overiden when defining the element. The custom element can also be extended as with other elements.

```ruby
class MyPage
  include PageMagic
  element SearchField, :search, selector: '.custom' do
    link(:extr_link, id: 'extra-link')
  do
end
```

## Hooks
PageMagic provides hooks to allow you to define actions that are executed when you pages and elements are interacted with.

**Note:** 
- You may well find PageMagic's [watchers](#watchers) useful.
- The following examples wait for actions to happen. You can of course write you own wait code or feel free try out our
 [wait_until](#waiting) helper:)

### On load hook
PageMagic lets you define an on_load hook for your pages. This will be executed when the browser thinks the page has been loaded.

```ruby
class Github
  # ... code defining elements as shown above
  
  on_load do
    # code that needs to run when the page has loaded
  end
end
```

### Element event hooks
Frequently, you are going to have to work with pages that make heavy use of ajax. For these occasions PageMagic provides `before_events` 
and `after_events` hooks that you use to perform custom action.

In the following example we have added watchers and event hooks to the SearchField custom element we defined in the 
[previous section](#custom-elements). Encapsulating the business logic here means that we can really add value to 
the pages that reuse this custom element

```ruby
class SearchField < PageMagic::Element
  selector name: 'q'
  watch(:url)
  after_events do
    wait_until { changed?(:url) }
  end
end
```

## Helper methods
Helper methods can be defined to avoid writing repetive page/element specific code outside of your pages and elements.

```ruby
class Github
  # ... code defining elements as shown above

  def search(project_name)
    search_field.set "#{project_name}\n"
  end
end
```

We can interact with helper in the same way as we did page elements.

```ruby
page.search('page_magic')
```

## Dynamic Selectors
In some cases you wont be able to specify the selector for an element until runtime. PageMagic allows you to handle 
such situations with support for dynamic selectors. In the case of our Github example it would be nice to select a 
particular result by supplying the owners organisation name. 

```ruby
class ResultsPage
  include PageMagic

  element :results do |organisation:|

    selector xpath: "//h3/a[contains(text(), '#{organisation}')]/../.."

    # code for sub elements
  end
end
```

In the above example the selector looks for an element that has a link containing text that includes that organisation.
The example uses a named parameter and is invoked as follows.
```ruby
page.results(organisation: 'lvlup')
```

# Starting a session
To start a PageMagic session simply decide what browser you want to use and pass it to PageMagic's `.session` method
```ruby
session = PageMagic.session(browser: :chrome, url: 'https://www.github.com')
```

Your session won't do much besides navigating to the given url until you have [mapped pages](#page-mapping) to it, so 
take a look at this next! 

**Note** PageMagic supports having multiple sessions using different browsers at the same time :)
 
## Rack applications and Rack::Test
To run a session against a rack application instead of a live site, simply supply the rack application when creating 
the session

```ruby
session = PageMagic.session(application: YourRackApp, url: '/path_to_start_at')
```

By default PageMagic uses the Rack::Test driver for capybara however you are free to use any browser you like as long 
as the [driver is registered](#drivers) for it.

```ruby
session = PageMagic.session(application: YourRackApp, browser: :your_chosen_browser, url: '/path_to_start_at')
```

Out of the box, PageMagic supports the following as parameters to browser:
- :chrome
- :firefox
- :poltergeist
- :rack_test

Under the hood, PageMagic is using [Capybara](https://github.com/jnicklas/capybara) so you can register any Capybara 
compliant driver you want. See [below](#registering-a-custom-driver) for how to do this.

**Note:** We don't want to impose particular driver versions so PageMagic does not list any as dependencies. Therefore 
you will need add the requiste gems to your Gemfile.

# Page mapping
With PageMagic you can map which pages should be used to handle which resources. Meaning that when a the page in the browser changes, PageMagic loads the correct PageObject class to handle it. This feature removes a lot of the juggling and brings back fluency to your code!

```ruby
# define what pages map to what
session.define_page_mappings '/' => GitHub, '/search' => ResultsPage
```
You can use even use regular expressions and provide more than one mapping to the same page object class.

**Note:** By default mappings are matched against a URL's path. In addition, PageMagic supports mapping against both 
query string parameters and the fragement identifer (see below). Any combination of these can be used to define a page mapping.

## Mapping against query string parameters
```ruby
browser.define_page_mappings PageMagic.mapping(parameters: {parameter_name: string_or_regex}) => ResultsPage                             
```

## Mapping against fragment identifiers
JavaScript MVC frameworks allow different resources to be mapped the fragment portion of URLs. That is the part of the URL that follows the [Fragement identififer](https://en.wikipedia.org/wiki/Fragment_identifier) (#). PageMagic supports mapping page_objects 
against URL fragments.

```ruby
browser.define_page_mappings PageMagic.mapping(fragment: string_or_regex) => ResultsPage                            
```

# Loading pages from source
PageMagic supports loading page objects using html source. This technique can be useful for getting quick feedback that 
your templates correctly render based on your view objects. I.e you can test your templates in isolation.
```ruby
class MyPage
  include PageMagic
  #element definitions
end

page_instance = Page.load(html_string)
```

# Watchers
PageMagic lets you set a watcher on any element. Use watchers to decide when things have changed. The `watch` method can be called from anywhere within an element definition. For PageObjects it can only be called from within hooks and helper methods.

**Note**: Watchers are not inherited

## Method watchers
Method watchers watch the output of the given method name.
```ruby
button :javascript_button, css: '.fancy_button' do
  watch(:url)
  
  after_events do
    wait_until{changed?(:url)}
  end
end
```

## Simple watchers
Use `watch` method passing two parameters, the first is the name of the element you want to keep 
an eye on and the second is the method that needs to be called to get the value that should be observed.

```ruby
element :product_row, css '.cta' do
  watch(:total, :text)
  
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
  watch(:total) do
    session.nav.total.text
  end
  
  after_events do
    wait_until{changed?(:total)}
  end
end
```

# Waiting
It's inevitable that if there is JavaScript on the page that you are going to have to wait for things to happen. PageMagic supplies the `wait_until` method that can be used anywhere you might need it. The wait_until method takes a block that it will execute until either that block returns true or the timeout occurs. See the method docs for details on configuring timeouts and retry intervals.

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
session = PageMagic.session(browser: webkit, url: 'https://www.github.com')
```
# Cucumber quick start
You can obviously use PageMagic anywhere you fancy but one of the places you might decide to use it is within a 
Cucumber test suite. If that's the case something like the following could prove useful.

## Helper methods
Put the following in to `features/support/page_magic.rb` to make these helpers available to all of your steps.

```ruby
require 'page_magic'
require 'active_support/inflector'
require 'your_pages'

World(Module.new do
        def page_class(string)
          "#{string}Page".delete(' ').constantize
        end

        def snake_case(string)
          string.delete(' ').underscore
        end

        def session
          $session ||= begin
            PageMagic.session(browser: :chrome, url: the_base_url).tap do |session|

              session.define_page_mappings '/login' => LoginPage,
                                           '/' => HomePage

            end
          end
        end
      end)
```
## Example steps
Use the [above](#helper-methods) helpers to navigate to pages with steps like the following.

```ruby
Given /^I am on the '(.*)' page$/ do |page_name|
  session.visit(page_class(page_name))
end

And /^I set '(.*)' to be '(.*)'$/ do |field, value|
  session.send(snake_case(field)).set value
end

When /^I click '(.*)'$/ do |element|
  session.send(snake_case(element)).click
end

Then /^I should be on the '(.*)' page$/ do |page_name|
  current_page = session.current_page.class
  expected_page = page_class(page_name)
  fail "On #{current_page}, expected #{expected_page}" unless current_page == expected_page
end
```
