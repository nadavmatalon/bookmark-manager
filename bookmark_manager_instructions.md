# Bookmark manager

### Completion time 3-4 days


This week's project is a bookmark manager. The goal is to expose you to the following aspects of web development, in addition to what we've studied before:

* Integration testing: Capybara (Monday)
* Relational databases (Tuesday and Wednesday)
* Security considerations (Thursday)

In addition to the technologies mentioned above, this project is going to be more challenging on the front-end. You shouldn't need more than we've covered in the previous weeks but you should expect to spend more time on the front-end, compared to Sudoku – web version. Of course, we'll also continue to be using the technologies we're familiar with: Sinatra, RSpec, etc.

## High-level specification

We are going to build a bookmark manager, similar to pineapple.io or delicious.com in spirit. A bookmark manager is a good use case for exploring how relational databases work.

A bookmark manager is a website to maintain a collection of links, organised by tags. You can use it to save a webpage you found useful. You can add tags to the webpages you saved to find them later. You can browse links other users have added.

The website will have the following options:

* Show a list of links from the database
* Add new links
* Add tags to the links
* Filter links by a tag

This is the basic view of the website. This tutorial will discuss how to build it, step by step. At the end of the section there are multiple exercises challenging you to extend the functionality of this website. 

![alt text](https://dchtm6r471mui.cloudfront.net/hackpad.com_jubMxdBrjni_p.52567_1380279073159_Screen%20Shot%202013-09-27%20at%2011.06.12.png "Bookmark Manager")

## First Steps

As you'd do with every new project, create a new repository on Github. Create an empty Sinatra application with a Gemfile and config.ru.

## Outline

To prevent this pad from getting very large, let's break it down into sections.


##Bookmark manager – Adding the database

In this project, we'll need to store the data in a database. Before we add any functionality, let's add a relational database to this project.

First you will have to install postgresql (unless you have installed it already). First install PostgreSQL. Postgres is a widely used open source relational database engine.

There are two ways of doing this. Downloading the app (2) will, sometimes, leave you with a non-working postgresql installation. We recommend using option 1.

1) Install it through Homebrew with "brew install postgresql" (after it has installed postgres follow the on screen instructions).

2)  In your terminal run

`brew install postgresql`

After homebrew has downloaded the software it will show you some installation instructions, follow them! Ok, they might not be that readable ;)

Make sure you run these commands after installing postgresql with homebrew:

`ln -sfv /usr/local/opt/postgresql/*.plist ~/Library/LaunchAgents`
`launchctl load ~/Library/LaunchAgents/homebrew.mxcl.postgresql.plist`

You can check your installation by running

`psql`

At first it can happen that you don't have a database named after your username (you will see a messags along the lines 'unknown database "ecomba"). Let's create that database for you so that you can loging without having to specify the database:

`psql postgres`

`postgres# create database "ecomba";`

`DATABASE CREATE`

`postgres# \q`



From now on you will be able to log in to postgresql without having to specify the database you want to log into.

To talk to the database, we'll need the datamapper gem. It's an ORM (Object-relational mapper), which means that it's providing a convenient way to interact with our data using classes and objects instead of working with database tables directly.

Another advantage of datamapper is that is can be used with a variety of database engines, not only postgres. This implies that we'll need to install an adapter to work with postgres, apart from the datamapper itself. Add these gems to your Gemfile:

```ruby
gem 'data_mapper'
gem 'dm-postgres-adapter'
```

Don't forget to run "bundle install" every time you update your Gemfile.

Then let's create our first model. Since our bookmark manager is going to manage collections of links, it'll certainly need a table to store them. So, create a model in lib/link.rb.
```ruby
# This class corresponds to a table in the database
# We can use it to manipulate the data
class Link

  # this makes the instances of this class Datamapper resources
  include DataMapper::Resource

  # This block describes what resources our model will have
  property :id,     Serial # Serial means that it will be auto-incremented for every record
  property :title,  String
  property :url,    String

end
```

This file describes the relationship between the table in the database (they don't exist yet) and this Ruby class. We'll see how it can be used in a minute.

Then, add this code to server.rb.


```ruby
env = ENV["RACK_ENV"] || "development"
# we're telling datamapper to use a postgres database on localhost. The name will be "bookmark_manager_test" or "bookmark_manager_development" depending on the environment
DataMapper.setup(:default, "postgres://localhost/bookmark_manager_#{env}")

require './lib/link' # this needs to be done after datamapper is initialised

# After declaring your models, you should finalise them
DataMapper.finalize

# However, the database tables don't exist yet. Let's tell datamapper to create them
DataMapper.auto_upgrade!
```

So, we begin by telling datamapper where our database is going to be. The second argument to setup() is called a connection string. It has the following format.

`dbtype://user:password@hostname:port/databasename`

By default Postgres.app is configured to accept connections from a logged in user without the password, so we omit them. Since postgres is running on the default port 5432, it doesn't have to be specified either.

After we require our models, datamapper will know what data schema we have in our project (because we include DataMapper::Resource in every model). After the models are finalised (checked for consistency), we can ask datamapper to create the tables.

However, datamapper will not create the database for us. We need to do it ourselves. 

In the terminal run psql to connect to your database server.


Psql is a text-based interface to talk to the database, much like irb is used to run Ruby code. Let's create both databases we need using SQL commands.

![alt text](https://dchtm6r471mui.cloudfront.net/hackpad.com_jubMxdBrjni_p.52567_1379937867691_Screen%20Shot%202013-09-23%20at%2012.44.14.png "terminal")

Finally, type 
`\q`
to exit psql.

Now we have everything we need to use datamapper in our code. Let's see how we could do it by writin an rspec test.

RSpec demonstration

First, add rspec to the Gemfile.
```ruby
group :development, :test do
  gem "rspec"
 end
 ```

Then, init the rspec files:
```ruby
rspec --init
```
Add this on top of spec/spec_helper:
```ruby
# Remember environment variables from week 1?
ENV["RACK_ENV"] = 'test' # because we need to know what database to work with

# this needs to be after ENV["RACK_ENV"] = 'test' 
# because the server needs to know
# what environment it's running it: test or development. 
# The environment determines what database to use.
require 'server'
``` 

Finally, create the spec/link_spec.rb:
```ruby
require 'spec_helper'

describe Link do

  context "Demonstration of how datamapper works" do

    # This is not a real test, it's simply a demo of how it works
    it 'should be created and then retrieved from the db' do
      # In the beginning our database is empty, so there are no links
      expect(Link.count).to eq(0)
      # this creates it in the database, so it's stored on the disk
      Link.create(:title => "Makers Academy", 
                  :url => "http://www.makersacademy.com/")
      # We ask the database how many links we have, it should be 1
      expect(Link.count).to eq(1)
      # Let's get the first (and only) link from the database
      link = Link.first
      # Now it has all properties that it was saved with.
      expect(link.url).to eq("http://www.makersacademy.com/")
      expect(link.title).to eq("Makers Academy")
      # If we want to, we can destroy it
      link.destroy
      # so now we have no links in the database
      expect(Link.count).to eq(0)
    end

  end

end

```

Check that it all works by running the test (make sure you have required "data_mapper" in server.rb).

`$ rspec`
Run options: include {:focus=>true}
```
All examples were filtered out; ignoring {:focus=>true}
.

Finished in 0.00991 seconds
1 example, 0 failures

Randomized with seed 41436

```

Why two databases?

A web project usually has at least three environments: development, test and production. An environment is the "mode" the project is running in, determined by the set of the environment variables (the environment the shell variables are in and the environment the project is running in are two different concepts that share the same name).

The environment the project is running in determines the behaviour of the project. For example, if we have an e-commerce project, our payment processing would be different for the three environment:
in production (when real customers use it), all credit cards would be charged for real
in development (when writing code), we would use special "development" credit cards that behave like real ones, except that no money is actually spent
in test (when running automated tests), we wouldn't even connect to the card processing centre to not slow down the tests

Depending on the environment, we may do or not do certain things: send real emails in production but only pretend to do it in a test environment. Our code can print extensive debugging information in development but only show succinct error messages in production.

So, getting back to the databases: we don't want to use the same database in different environments. Imagine you have one million users registered on your website. You don't want to use the same database for development. When you launch the website locally you only want to have a database with a few users that you control manually. And when you run your tests, you want your database to be empty because every test assumes that there is nothing there that wasn't created explicitely. What happens if your test deletes all data from the database and you run in on a production or development database? You'd lose data. So, we really need to use one database per environment.

That is why we are checking what environment we're in, defaulting to development.

```ruby
env = ENV["RACK_ENV"] || "development"
```

And then we select the database based on the environment.

```ruby
DataMapper.setup(:default, "postgres://localhost/bookmark_manager_#{env}")
```

Finally, in our spec_helper we specify the environment, so that our tests were using the right database.

```ruby
ENV["RACK_ENV"] = 'test'
```

Current state is on Github.
https://github.com/makersacademy/bookmark_manager/tree/24321e022f78f1275b77dcdff32e2df963d281f2

## Cleaning the database

When a test runs, it assumes that the database is empty. The test is not obliged to leave the database clean, though. We need to take care of this ourselves. Add the database_cleaner gem to the Gemfile and install it. Then, require it in the spec_helper and configure RSpec to use it.
```ruby
RSpec.configure do |config|

  config.before(:suite) do
    DatabaseCleaner.strategy = :transaction
    DatabaseCleaner.clean_with(:truncation)
  end

  config.before(:each) do
    DatabaseCleaner.start
  end

  config.after(:each) do
    DatabaseCleaner.clean
  end
  
end
```

This will make sure that the database is cleared after every test run.

Current State on Github
https://github.com/makersacademy/bookmark_manager/tree/15f77fecce729e2a9225f3ac2d369e201f6ce142

# Bookmark manager – Managing links and tags

Browsing links

Let's write our first integration test using Capybara first. First, add capybara to your Gemfile and install it. Then, require and configure it in spec_helper as instructed on the capybara github page.

```ruby
require 'capybara/rspec'

Capybara.app = Sinatra::Application.new
```

Then, create spec/features folder where our integration tests will be. Create the first test (listing_all_links_spec.rb) that visits the homepage and checks that the link we put in the database is there.
```ruby
require 'spec_helper'

feature "User browses the list of links" do

  before(:each) {
    Link.create(:url => "http://www.makersacademy.com",
                :title => "Makers Academy")
  }

  scenario "when opening the home page" do
    visit '/'
    expect(page).to have_content("Makers Academy")
  end
end
```

So, this test creates one link, goes to the homepage and expects to see it there (well, not exactly, it just looks for "Makers Academy" words somewhere on the page). If you run the test, it should fail.
```
Failures:

  1) User browses the list of links when opening the home page
     Failure/Error: expect(page).to have_content("Makers Academy")
       expected to find text "Makers Academy" in "Welcome to the bookmark manager"
     # ./spec/features/listing_all_links_spec.rb:11:in `block (2 levels) in <top (required)>'
```

This is because we haven't written any code to show the links on the homepage. Let's add it.

Current links:
```html
<ul>
  <% @links.each do |link| %>
    <li><a href="<%= link.url %>"><%= link.title %></a></li>
  <% end %>
</ul>
```
```ruby
get '/' do
  @links = Link.all
  erb :index
end
```

Now our tests pass.
```

Finished in 0.03551 seconds
2 examples, 0 failures
```

Current state is on Github.
https://github.com/makersacademy/bookmark_manager/tree/7d35ba70c772421e64999eac68a2e28f0501780b


Submitting a new link

So, let's add a few basic features to the website. First, we need to somehow submit new links. Let's add a new test for it, adding_links_spec.rb.

```ruby
require 'spec_helper'

feature "User adds a new link" do
  scenario "when browsing the homepage" do
    expect(Link.count).to eq(0)
    visit '/'
    add_link("http://www.makersacademy.com/", "Makers Academy")
    expect(Link.count).to eq(1)
    link = Link.first
    expect(link.url).to eq("http://www.makersacademy.com/")
    expect(link.title).to eq("Makers Academy")
  end

  def add_link(url, title)
    within('#new-link') do
      fill_in 'url', :with => url
      fill_in 'title', :with => title
      click_button 'Add link'
    end      
  end
end
```

The code should be self-explanatory. We expect to have no links until we go to the homepage and fill out the form inside #new-link element and submit it. Afterwards, we'll have one link in the database with the properties that we specified when creating it.

This test fails, so let's make it pass. First, we'll need to create the form in question.

```html
<div id="new-link">
  <form action="/links" method="post">
    Url: <input type="text" name="url">
    Title: <input type="text" name="title">
    <input type="submit" value="Add link">
  </form>
</div>
```

Then we'll need to add a new route that will handle the form submission.

```ruby
post '/links' do
  url = params["url"]
  title = params["title"]
  Link.create(:url => url, :title => title)
  redirect to('/')
end
```

Current state is on Github.
https://github.com/makersacademy/bookmark_manager/tree/8844773e81ba888327a1bef46737c6cf5c36597f

## Adding tags to links

By now we have a web application that allows us to add new links to the database and show the entire list on the front page. We have integration tests that give us comfort that if something breaks, we'll know about it straight away.

Let's implement a new feature: allowing links to have tags associated with them. As usual, let's start with a test.
```ruby

  scenario "with a few tags" do
    visit "/"
    add_link("http://www.makersacademy.com/", 
                "Makers Academy", 
                ['education', 'ruby'])    
    link = Link.first
    expect(link.tags).to include("education")
    expect(link.tags).to include("ruby")
  end

  def add_link(url, title, tags = [])
    within('#new-link') do
      fill_in 'url', :with => url
      fill_in 'title', :with => title
      # our tags will be space separated
      fill_in 'tags', :with => tags.join(' ')
      click_button 'Add link'
    end      
  end
  ```

Note that we modified add_link() method to have the third parameter with a default value to make sure it's still compatible with the other test we wrote earlier. Of course, our test fails.

```

1) User adds a new link with a few tags
     Failure/Error: expect(link.tags).to include("education")
     NoMethodError:
       undefined method `tags' for #<Link:0x007fe22c3a95b0>
     # ./spec/features/adding_links_spec.rb:19:in `block (2 levels) in <top (required)>'
```

So, the test tells us that the method "tags" that we expect to exist is undefined. This is because our Link model doesn't have any tags associated with it. Let's add a many-to-many relationship to our Link model.
```ruby
has n, :tags, :through => Resource
```

The details of how datamapper works with many-to-many relationships (:through => Resource) are well described in its documentation.

Let's go back and run the test. We get another error:

Cannot find the child_model Tag for Link in tags (NameError)

It means that the Link model now expect a Tag model to exist but we never defined it.

Before we do it, let's discuss the process we're going through. We have written a test that describes the functionality we want to see. Then we ran it and it highlighted a problem (no tags associated to a link). We fixed just that problem, no more, no less. We didn't create the Tag class straight away. Then we ran the test again and it told us that we didn't have the model Tag. This is when we decided to create the model Tag to get past this particular error. We'll be repeating this process several times over.

This is what is called test-driven development. You shouldn't merely have tests, they should drive the coding process. On many occasions you'll be able to predict the next error and you'll be tempted to fix a few things in one go. For example, if there were no tags linked to the Link model it was obvious that we should have created a many-to-many relationship and created the Tag model as well. However, be careful not to jump too far: the more code you write without the tests guiding you, the more likely you are to make an error. Some developers prefer to follow test messages very closely, doing the absolute minimum of work required to make them pass. Some move a few error messages at a time (like we've done before when we wrote our first test and wrote a dozen lines of code in one go. There isn't a one rule fits all approach. However, if you're unsure, follow the tests closely: they will guide you towards writing only the necessary amount of good code to get the job done.

So, let's create the Tag model that also has a many-to-many relationship to Link.

```ruby
class Tag

  include DataMapper::Resource

  has n, :links, :through => Resource

  property :id, Serial
  property :text, String
  
end
```

Note that we're doing a few things other than creating an empty datamapper model without letting the tests tell us that we need to do it (add the relationship with Link, add the text property). Use your best judgement when choosing how fast to go.

Let's move over to the next error.
```

2) User adds a new link with a few tags
     Failure/Error: fill_in 'tags', :with => tags.join(' ')
     Capybara::ElementNotFound:
       Unable to find field "tags"
```

Our test wants to fill out a field that doesn't exist. Let's fix it.
```html
Tags: <input type="text" name="tags">
```

Next error:
```

Failure/Error: expect(link.tags).to include("education")
       expected [] to include "education"
```

So, the test is filling out the form correctly since we added a new input fields but the data doesn't end up in the database. Time to fix it in server.rb.
```ruby

tags = params["tags"].split(" ").map do |tag|
  # this will either find this tag or create
  # it if it doesn't exist already
  Tag.first_or_create(:text => tag)
end
Link.create(:url => url, :title => title, :tags => tags)
```

Note that we're searching for a tag record in the database (or creating an instance of the Tag class if it doesn't exist) and then passing an array of instances to Link, as opposed to passing just the text. This is because a Tag is not simply a string, it's a database record that has text and id but may have other properties in the future (user_id of the user who created it, created_at timestamp, etc).

However, if we run the test, we'll still get an error.

```
Failure/Error: expect(link.tags).to include("education")
       expected [#<Tag @id=1 @text="education" @link_id=4>, #<Tag @id=2 @text="ruby" @link_id=4>] to include "education"
       Diff:
       @@ -1,2 +1,2 @@
       -["education"]
       +[#<Tag @id=1 @text="education" @link_id=4>, #<Tag @id=2 @text="ruby" @link_id=4>]
```

It turns out we made a mistake in out test. Instead of expecting the link.tags array to contain strings, we should expect it to contain instances of Tag object. Let's fix the test by mapping the Tag instances to the text they contain.

```ruby

expect(link.tags.map(&:text)).to include("education")
expect(link.tags.map(&:text)).to include("ruby")

```
Now all our tests pass.

```
Finished in 0.12076 seconds
4 examples, 0 failures
```
Current state is on Github.
https://github.com/makersacademy/bookmark_manager/tree/88dd9bc90041fc02dd5f335ad4ddfc0eab430c4e

## Filtering by tag

Adding tags to links is useful but it'd be even more useful to be able to filter links by a tag. Let's write a test for this in listing_all_links_spec first.

```ruby
scenario "filtered by a tag" do
  visit '/tags/search'
  expect(page).not_to have_content("Makers Academy")
  expect(page).not_to have_content("Code.org")
  expect(page).to have_content("Google")
  expect(page).to have_content("Bing")
end
```

Let's also update the before(:each) block to create some test data.

```ruby
  before(:each) {
    Link.create(:url => "http://www.makersacademy.com",
                :title => "Makers Academy", 
                :tags => [Tag.first_or_create(:text => 'education')])
    Link.create(:url => "http://www.google.com", 
                :title => "Google", 
                :tags => [Tag.first_or_create(:text => 'search')])
    Link.create(:url => "http://www.bing.com", 
                :title => "Bing", 
                :tags => [Tag.first_or_create(:text => 'search')])
    Link.create(:url => "http://www.code.org", 
                :title => "Code.org", 
                :tags => [Tag.first_or_create(:text => 'education')])
  }
  ```

Sure enough, the test fails because Sinatra returns a "404 Not Found" page for the route that doesn't exist yet. Let's add the route.

```ruby
get '/tags/:text' do
  tag = Tag.first(:text => params[:text])
  @links = tag ? tag.links : []
  erb :index
end
```

First we find the tag that we need (note the use of a named parameter in the route). Then, if the tag exists, we get associated links. Otherwise, we just return an empty array.

Current state is on Github
https://github.com/makersacademy/bookmark_manager/tree/e45ed5d9c3289c8320632e6aadcc56c3d624fbcc

##Bookmark manager – Adding user accounts

Let's implement basic user account functionality using what we learned in Security. We want users to be able to register on the website, so that every link and tag could be attributed to a specific user. This section will rely on your understanding of what we (will) have discussed in Security.

The goal of this exercise is to demonstrate how to create a user management system from scratch without using user management libraries (we'll be using them later in the course, though).

We will add the following functionality:
*Sign up with an email and a password
*Sign in
*Sign out
*A welcome message for the logged in user
*Every link and every tag will be linked to the user that created it, unless the user was anonymous

We want to have a separate database table for all our users. For this we'll need to have a User model that will store the email and password-related information (hash, salt).

Bookmark manager - Adding user accounts - signing up
Let's begin with a test, as usual. The integration test should go to /spec/features/user_management_spec.rb.
```ruby
require 'spec_helper'

feature "User signs up" do
 
  # Strictly speaking, the tests that check the UI 
  # (have_content, etc.) should be separate from the tests 
  # that check what we have in the DB. The reason is that 
  # you should test one thing at a time, whereas
  # by mixing the two we're testing both 
  # the business logic and the views.
  #
  # However, let's not worry about this yet 
  # to keep the example simple.

  
  scenario "when being logged out" do    
    lambda { sign_up }.should change(User, :count).by(1)    
    expect(page).to have_content("Welcome, alice@example.com")
    expect(User.first.email).to eq("alice@example.com")        
  end

  def sign_up(email = "alice@example.com", 
              password = "oranges!")
    visit '/users/new'
    expect(page.status_code).to eq(200)
    expect(page.status_code).to eq(200)
    fill_in :email, :with => email
    fill_in :password, :with => password
    click_button "Sign up"
  end

end
```

Running the test tells us that we haven't got the User class. Let's create a basic model in /lib/user.rb (where the Link model is).

```ruby
class User

  include DataMapper::Resource

  property :id, Serial
  property :email, String
  
end
```

A word of caution. If you declare a property, you shouldn't declare an accessor (or reader, or writer) for that property because you'll override datamapper's default functionality. Ruby will not throw any warning in this case. In other words, if you do this:

```ruby
# this is wrong!
property :description, Text
attr_reader :description
```

you will not be able to get the description back from the database.

The next error in our test suite is not having the form to fill in to sign up. That's easy to fix by updating app/server.rb (or just server.rb if you chose to place it in the root folder).

```ruby
get '/users/new' do
  # note the view is in views/users/new.erb
  # we need the quotes because otherwise
  # ruby would divide the symbol :users by the
  # variable new (which makes no sense)
  erb :"users/new"
end

```


and /views/users/new.erb.

```html

<h1>Please sign up</h1>

<form action="/users" method="post">
  Email: <input name="email" type="text">
  Password: <input name="password" type="password">
  <input type="submit" value="Sign up">
</form>

```

Now the test will be able to fill out the form but the form submits to the route POST /users that doesn't exist. Let's fix this in /app/server.rb

```ruby
post '/users' do
  User.create(:email => params[:email], 
              :password => params[:password])
  redirect to('/')
end
```

This code is straighforward enough. However, we already have a problem. Our User model doesn't know anything about the password, so our test still fails. Let's extend our User class (/lib/user.rb).

```ruby
# bcrypt will generate the password hash
require 'bcrypt'
class User

  include DataMapper::Resource

  property :id, Serial
  property :email, String
  # this will store both the password and the salt
  # It's Text and not String because String holds 
  # 50 characters by default
  # and it's not enough for the hash and salt
  property :password_digest, Text

  # when assigned the password, we don't store it directly
  # instead, we generate a password digest, that looks like this:
  # "$2a$10$vI8aWBnW3fID.ZQ4/zo1G.q1lRps.9cGLcZEiGDMVr5yUP1KUOYTa"
  # and save it in the database. This digest, provided by bcrypt,
  # has both the password hash and the salt. We save it to the 
  # database instead of the plain password for security reasons.
  def password=(password)
    self.password_digest = BCrypt::Password.create(password)
  end

end

```

Now our user is created in the database but the test would still fail because it expects to see a welcome message for the user. Let's log in the user automatically on sign up. To do this, we'll store the user id in the session (we looked at how sessions work in Sudoku – web version).

First, we need to enable the sessions and set the encryption key to make sure nobody can tamper with our cookies. This is done by changing Sinatra's configuration, so it goes into /server.rb.

```ruby
enable :sessions
set :session_secret, 'super secret'

Then, let's save the user id in the session after it's created (/server.rb).

post '/users' do
  user = User.create(:email => params[:email], 
                     :password => params[:password])  
  session[:user_id] = user.id
  redirect to('/')
end

```

Then, let's create a helper that will give us access to the current user, if logged in (server.rb).

```ruby
helpers do

  def current_user    
    @current_user ||=User.get(session[:user_id]) if session[:user_id]
  end

end

```

Finally, let's use this helper in the layout file (/views/layout.erb)

```html
<body>
  <% if current_user %>
    Welcome, <%= current_user.email %>
  <% end %>
  <%= yield %>
</body>

```

Finally, make sure 'bcrypt-ruby' is in your Gemfile and it's installed. Our test finally passes.

Let's clean the code up a little bit by extracting the helpers and datamapper-related code to external files and moving server.rb, views and helpers to /app. Now the codebase looks a little bit cleaner.

Current state is on Github
https://github.com/makersacademy/bookmark_manager/tree/1b6fada4c9fdaa5e44cc62fdd31ddf5d7706d139

### Bookmark manager - Adding user accounts - Password confirmation

Now a user can register on our website but it would be nice to ask for password confirmation on registration to make sure there's no mistake in the password. Let's start by adding a test for this.
```ruby
  scenario "with a password that doesn't match" do
    lambda { sign_up('a@a.com', 'pass', 'wrong') }.should change(User, :count).by(0)    
  end

  def sign_up(email = "alice@example.com", 
              password = "oranges!", 
              password_confirmation = "oranges!")
    visit '/users/new'
    fill_in :email, :with => email
    fill_in :password, :with => password
    fill_in :password_confirmation, :with => password_confirmation
    click_button "Sign up"
  end

```

So we pass a non-matching password and we expect the user to not be created. Modify the erb template accordingly and then add the virtual attributes to the User model.

```ruby
attr_reader :password
attr_accessor :password_confirmation

# this is datamapper's method of validating the model.
# The model will not be saved unless both password
# and password_confirmation are the same
# read more about it in the documentation
# http://datamapper.org/docs/validations.html
validates_confirmation_of :password

```

The reason we need the reader for :password and :password_confirmation is that datamapper should have access to both values to make sure they are the same.

The reason we need the writer for :password_confirmation is that we're now passing the password confirmation to the model in the controller.

```ruby
post '/users' do
  user = User.create(:email => params[:email], 
              :password => params[:password],
              :password_confirmation => params[:password_confirmation])  
  session[:user_id] = user.id
  redirect to('/')
end
```

However, you may wonder what happens to :password since we wrote a custom writer for this property.

```ruby
  def password=(password)
    self.password_digest = BCrypt::Password.create(password)
  end
```

Because we have a custom writer for this property, we'll never be storing the plain text password in an instance variable and datamapper will be unable to compare it to the password confirmation. Let's fix it by modifying our writer.

```ruby
  def password=(password)
    @password = password
    self.password_digest = BCrypt::Password.create(password)
  end

```

Now the test passes.

Current state is on Github
https://github.com/makersacademy/bookmark_manager/tree/f41a3a2b35451eadd0773e0abbc8e85aba481e90

### Bookmark manager - Adding user accounts - Handling input errors

Right now our code has no logic for handling the situation when the user enters an incorrect password confirmation. It just fails silently, redirecting the user to the homepage. In the controller, the user.id will be nil because datamapper won't be able to save the record if the passwords don't match.

```ruby 
post '/users' do
  user = User.create(:email => params[:email], 
              :password => params[:password],
              :password_confirmation => params[:password_confirmation])    
  # the user.id will be nil if the user wasn't saved
  # because of password mismatch
  session[:user_id] = user.id
  redirect to('/')
end
```

Let's extend the test to expect a redirection back to the sign up form if the passwords don't match.
```ruby

  scenario "with a password that doesn't match" do
    lambda { sign_up('a@a.com', 'pass', 'wrong') }.should change(User, :count).by(0) 
    expect(current_path).to eq('/users')   
    expect(page).to have_content("Sorry, your passwords don't match")
  end
```

This test expects the website to stay at /users, instead of navigating to the home page (note the use of the current_path helper, provided by capybara). The reason is that we are submitting the form to /users and we don't want the redirection to happen if the user is not saved because we will lose the unsaved data.

Let's suppose we have a longer sign up form. A user fills out 20 fields but makes a mistake in password_confirmation. If we refresh the page by doing a redirect, we'll lose all information that was entered in the form because it was never saved to the database. This information only exists in memory, as properties of the invalid User model that is alive only for the duration of this request.

So, instead of redirecting the user, let's show the same form but this time we'll populate it using our invalid User object.
```ruby

post '/users' do
  # we just initialize the object
  # without saving it. It may be invalid
  user = User.new(:email => params[:email], 
              :password => params[:password],
              :password_confirmation => params[:password_confirmation])  
  # let's try saving it
  # if the model is valid,
  # it will be saved
  if user.save
    session[:user_id] = user.id
    redirect to('/')
    # if it's not valid,
    # we'll show the same
    # form again
  else
    erb :"users/new"
  end
end
```

This is a fairly common pattern of handling potential errors. Instead of creating the object straight away, you initialise it, attempt to save and handle both possibilities.

However, how will the data (in our case the email the user entered) make its way from the user object to the re-rendered form? Let's make the user an instance variable and update the view.

```ruby
post '/users' do
  @user = User.new(:email => params[:email], 
              :password => params[:password],
              :password_confirmation => params[:password_confirmation])  
  if @user.save
    session[:user_id] = @user.id
    redirect to('/')
  else
    erb :"users/new"
  end
end
```

```html

Email: <input name="email" type="text" value="<%= @user.email %>">
```

Now the email will be part of the form when it's rendered again.

Because the view now expects @user instance variable, we must make sure that it's available in the /users/new route as well.

```ruby
get '/users/new' do
  @user = User.new
  erb :"users/new"
end

```

An new instance of the user will simply return nil for @user.email.

Finally, let's display a flash message, notifying the user of the error. Add the rack-flash3 gem as described in Sudoku – web version and set the flash before the view is re-rendered.

```ruby

if @user.save
  session[:user_id] = @user.id
  redirect to('/')
else
  flash[:notice] = "Sorry, your passwords don't match"
  erb :"users/new"
end
```

Finally, display it in the layout.erb.

```ruby
<% if flash[:notice] %>
  <div id="notice"><%= flash[:notice] %></div>
<% end %>
```

It will be displayed on top the page that was re-rendered (note the /users path).

![alt text](https://dchtm6r471mui.cloudfront.net/hackpad.com_jubMxdBrjni_p.52567_1380105990218_Screen%20Shot%202013-09-25%20at%2011.46.01.png "bookmark manager")


Finally, our tests pass.
```
Finished in 0.40513 seconds
7 examples, 0 failures
```
Current state is on Github
https://github.com/makersacademy/bookmark_manager/tree/bf1820c8e3ab276fae6e6d5be64cb2456451024c

### Bookmark manager - Adding user accounts - Three level of data checks

Right now we don't do any validations except that the passwords should match. However, we shouldn't be registering the user in the first place if the email is already taken.

In general, there are three levels at which you can and should check for the uniqueness in a well-designed application.

Firstly, you should check it before the form is submitted by sending a request to the server to check if the form is valid. This is done using Javascript that we haven't covered yet, so let's ignore it for now. You can't rely exclusively on this check anyway because the form may be submitted directly without the page being rendered or javascript may be disabled.

You can see an example of it in action on Github if you try to create a new repository with a non-unique name.

![alt text](https://dchtm6r471mui.cloudfront.net/hackpad.com_jubMxdBrjni_p.52567_1380107708596_Screen%20Shot%202013-09-25%20at%2012.13.52.png "bookmark manager")

Secondly, you should check for the uniqueness of records on the model level by using validations. This will allow you to display meaningful error messages. So, on the model level we want to have a uniqueness validation:

```ruby
validates_uniqueness_of :email
```

This datamapper validation will check if a record with this email exists before trying to create a new one.

Finally, you should introduce database-level constraints. This is a safety check that protects the database in case any data is written directly, bypassing the model. For example, if you need to batch-add 10,000 new users from a text file, you may not want to initialise your User model for every record for performance reasons. Instead, you'll write to the database directly bypassing datamapper. To account for any cases when you may want to write to the database bypassing your models, you need to have database-level contraints.

```ruby
property :email, String, :unique => true
```

This will generate SQL that will create a unique index on that field.

```
CREATE TABLE "users" ("id" SERIAL NOT NULL, "email" VARCHAR(50), "password_digest" TEXT, PRIMARY KEY("id"))
CREATE UNIQUE INDEX "unique_users_email" ON "users" ("email")
```
This unique index on users.email will make sure that no records with duplicate emails will ever be saved to the database.

In datamapper's case, creating a unique index automatically implies the necessity of the validation, so this code
```ruby
validates_uniqueness_of :email
```

would be unnecessary. When using other ORMs, double check if creating a unique index implies a model-level validation.

### Bookmark manager - Adding user accounts - Preventing duplicate registrations

Let's write a test first, as usual, checking that we can't register the same user twice.
```ruby
  scenario "with an email that is already registered" do    
    lambda { sign_up }.should change(User, :count).by(1)
    lambda { sign_up }.should change(User, :count).by(0)
    expect(page).to have_content("This email is already taken")
  end

  ```

We need to do two things. Firstly, we need to put constrains on the email field.

property :email, String, :unique => true, :message => "This email is already taken"

We're setting the error message datamapper is going to return explicitely even though a very similar message would be used by default if we didn't specify it.

Secondly, we need to refactor our controller code. Right now it looks like this.

```ruby
if @user.save
  session[:user_id] = @user.id
  redirect to('/')
else
  flash[:notice] = "Sorry, your passwords don't match"
  erb :"users/new"
end
```

The problem is that the only error message that this controller can show is the one about passwords not being the same. However, we need to show various error messages and even several messages at the same time, if necessary. Let's take the list of messages from datamapper.

```ruby
if @user.save
    session[:user_id] = @user.id
    redirect to('/')
  else
    flash.now[:errors] = @user.errors.full_messages
    erb :"users/new"
  end
```

Note that we're switching to using flash[:errors] instead of flash[:notice]. Given that these errors prevent us from proceeding further, it's more appropriate to call them errors.

We're also using flash.now instead of just flash. By default, a flash message is available for both the current request and the next request. This is very convenient if we're doing a redirect. However, since we are just re-rendering the page, we just want to show the flash for the current request, not for the next one. If we use flash[:errors], then after the user fixes the mistakes, we'll be redirected to the homepage where we'll see our message again.

The @user.errors object contains all validation errors. It can be used to get errors for a given field (if you want to display the error next to a specific field). The full_messages method just returns an array of all errors as strings. Let's display them in our layout file.

```html
<% if flash[:errors] && !flash[:errors].empty? %>
  Sorry, there were the following problems with the form. 
  <ul id="errors">
    <% flash[:errors].each do |error| %>
      <li><%= error %></li>
    <% end %>
  </ul>
<% end %>
```

Now we get a list of errors if the user is trying to both register with the same email and mistypes the password.


![alt text](https://dchtm6r471mui.cloudfront.net/hackpad.com_jubMxdBrjni_p.52567_1380116432734_Screen%20Shot%202013-09-25%20at%2014.39.55.png "bookmark manager")


We have all the code we need to make our tests pass. (If your tests fail, the chances are the database is in an inconsistent state, see the next section).

Current state is on Github
https://github.com/makersacademy/bookmark_manager/tree/44a6f6d79ab74d5da01487c14ac5929349e74651

### Bookmark manager - Adding user accounts - Rake tasks for database management

Since we are changing the schema of the database in a destructive way (creating a unique index), we need to execute DataMapper.auto_migrate! instead of DataMapper.auto_upgrade! after we create a unique index.

Right now our data_upgrade! call is in data_mapper_setup but this creates two problems. First, we don't want to edit this file every time we want to run data_migrate! instead. Second, we don't want to run data_upgrade every single time we respond to a request. Let's create a rake task for these operations, so that we could call them manually when we need to.

Rake is a tool for running automated tasks. The tasks are defined in Rakefile (with capital R). Put this Rakefile in the root folder of the project.

```ruby
require 'data_mapper'
require './app/data_mapper_setup'  

task :auto_upgrade do  
  # auto_upgrade makes non-destructive changes. 
  # If your tables don't exist, they will be created
  # but if they do and you changed your schema 
  # (e.g. changed the type of one of the properties)
  # they will not be upgraded because that'd lead to data loss.
  DataMapper.auto_upgrade!
  puts "Auto-upgrade complete (no data loss)"
end

task :auto_migrate do
  # To force the creation of all tables as they are 
  # described in your models, even if this
  # may lead to data loss, use auto_migrate:
  DataMapper.auto_migrate!
  puts "Auto-migrate complete (data could have been lost)"
end
# Finally, don't forget that before you do any of that stuff, 
# you need to create a database first.
```


The syntax should be self-explanatory. We define two tasks: "auto_migrate" and "auto_upgrade". Whenever we want to run any of them, we just invoke rake from the command line:

```
$ rake auto_migrate
```

This way you can upgrade or migrate your database manually after every change to the model. Ruby on Rails makes extensive use of Rake tasks, as we'll see later.

Current state is on Github
https://github.com/makersacademy/bookmark_manager/tree/a97fbdb0d12210277d6dca158b03ce6c88d07677

### Bookmark manager - Adding user accounts - Signing in
The users can sign up on our website but there's no way to sign in if you happen to be logged out (not that we have logging out functionality yet but it's coming). Let's write a test for signing in.
```ruby
feature "User signs in" do

  before(:each) do
    User.create(:email => "test@test.com", 
                :password => 'test', 
                :password_confirmation => 'test')
  end

  scenario "with correct credentials" do
    visit '/'
    expect(page).not_to have_content("Welcome, test@test.com")
    sign_in('test@test.com', 'test')
    expect(page).to have_content("Welcome, test@test.com")
  end

  scenario "with incorrect credentials" do
    visit '/'
    expect(page).not_to have_content("Welcome, test@test.com")
    sign_in('test@test.com', 'wrong')
    expect(page).not_to have_content("Welcome, test@test.com")
  end

  def sign_in(email, password)
    visit '/sessions/new'
    fill_in 'email', :with => email
    fill_in 'password', :with => password
    click_button 'Sign in'
  end

end
```

The only interesting part in this test is line 24. Why do we want to sign_in at "/sessions/new", and not at "/sign_in", "/users/sign_in", "/login" or something like this? Technically, it would work but it wouldn't be as elegant.

When signing in or out, we are manipulating a session: creating it, destroying it, and displaying a form to create it. By creating urls that define actions that apply to resources, we will achieve more elegant and easy to understand urls. Compare this

```
/users/new
/users
/users/edit
/sessions/new
/sessions
```

to this
```

/create_user_form
/create_user
/edit_user_form
/edit_user
/sign_in_form
/sign_in
/logout
```

The first approach is far more elegant. We've barely touched how urls should be defined (it's a slightly larger topic) but we'll go into details in Routing and REST.

To make this work, we'll need a form in sessions/new

```html
Please sign in.

<form method="post" action="/sessions">
  Email: <input type="text" name='email'>
  Password: <input type="password" name='password'>
  <input type="submit" value="Sign in">
```
a method to show this form:
```ruby 
get '/sessions/new' do
  erb :"sessions/new"
end
```

a method to handle form submission

```ruby
post '/sessions' do
  email, password = params[:email], params[:password]
  user = User.authenticate(email, password)
  if user
    session[:user_id] = user.id
    redirect to('/')
  else
    flash[:errors] = ["The email or password is incorrect"]
    erb :"sessions/new"
  end
end
```

and the User.authenticate method that we'll get to in a second.

Note that we're using the same pattern we used before: we try to obtain the user object by authenticating using the email and password provided and then check if we got one. If we did, we sign the user in and redirect. If we didn't, we show an error and display the form again.

Finally, we need a class method to authenticate a user.

```ruby
def self.authenticate(email, password)
  # that's the user who is trying to sign in
  user = first(:email => email)
  # if this user exists and the password provided matches
  # the one we have password_digest for, everything's fine
  #
  # The Password.new returns an object that overrides the ==
  # method. Instead of comparing two passwords directly
  # (which is impossible because we only have a one-way hash)
  # the == method calculates the candidate password_digest from
  # the password given and compares it to the password_digest
  # it was initialised with.
  # So, to recap: THIS IS NOT A STRING COMPARISON 
  if user && BCrypt::Password.new(user.password_digest) == password
    # return this user
    user
  else
    nil
  end
end

```

Since we're using bcrypt to generate a one-way hash, we cannot compare the passwords directly. We genuinely have no way of recovering the actual password. It is lost forever. However, what we do have is a digest that we can use to check if the password the user is trying to log in with is correct.

So we pass the password that the user is trying to log in with to the == method of the Password class. That method then calculates the digest for that password and compares it to the one in the database. It could look like this (not real bcrypt code):

```ruby
module BCrypt
  class Password
    def initialize(digest)
        @digest = digest
    end
    def ==(password)        
        @digest == digest(salt(@digest), password)
    end
    def digest(salt, password)
        # compute the digest
        # by using bcrypt magic.
        # return something like
        # "$2a$10$vI8aWBnW3fID.ZQ4/zo1G.q1lRps.9cGLcZEiGDMVr5yKUOYTa"
    end
  end
end
```

Current state is on Github
https://github.com/makersacademy/bookmark_manager/tree/3beb8ac44357ceedf643bcbc9fccd92459faa92d

### Bookmark manager - Adding user accounts - Signing out

So far we learned how to create the users and sign them in. Let's see how we can log them out.

Since "signed in" only means that there's a user_id in the session, logging the user out is as simple as setting the session[:user_id] to nil. Let's write a test.

```ruby
feature 'User signs out' do

  before(:each) do
    User.create(:email => "test@test.com", 
                :password => 'test', 
                :password_confirmation => 'test')
  end

  scenario 'while being signed in' do
    sign_in('test@test.com', 'test')
    click_button "Sign out"
    expect(page).to have_content("Good bye!") # where does this message go?
    expect(page).not_to have_content("Welcome, test@test.com")
  end

end
```

Since the sign_in helper is now used for more than one feature (sign in and sign out), let's extract it into an separate helper and include it as a module:

```ruby
require_relative 'helpers/session'

include SessionHelpers
```

The module now contains the methods sign_in and sign_up that we used to have in user_management_spec.

We will now need to display the Sign Out button that the test expects. The layout is a good place to do it since we'll need it on all pages of our site.

```html
  <% if current_user %>
    Welcome, <%= current_user.email %>
    <form method="post" action="/sessions">
      <input type="hidden" name="_method" value="delete">
      <input type="submit" value="Sign out">
    </form>
  <% end %>

```
The form sends a POST request to /sessions but it also includes a hidden field _method (note the underscore) with value "delete". The reason is that the common convention for a url that destroys a resource is sending a DELETE request to /resource_url. However, modern browsers are unable to send any requests other than GET or POST when the form is being submitted. A common solution to this problem, used by both Sinatra and Ruby on Rails, is to include a hidden field called _method that will override the actual type of request. So, when Sinatra receives this request, it will behave as if it were a DELETE request and not a POST request. Therefore, the handler for this form needs to specify "delete" as an HTTP verb:


Finally, let's add support for flash[:notice] in our layout.
```html
  <% if flash[:notice] %>
    <div id="notice">
      <%= flash[:notice] %>
    </div>
  <% end %>
```

The tests pass, so we know that the user can now be signed out.

Now it's a good time to refactor our code a little bit. Let's install 'sinatra-partial' gem and use it like we did in Sudoku – web version to extract the welcome message and flash from the layout. Let's also extract all actions from server.rb into specific controllers in the /app/controllers folder. After we do this, our server.rb is nice and clean, containing only require statements and high-level configuration. Let's also move the models from /lib to /app/models to make sure that the models, views and controllers are in one place (incidentally, we're following Ruby on Rails naming conventions to some extent).

Current state is on Github
https://github.com/makersacademy/bookmark_manager/tree/2e09228d334fd8009296653dfd55768520734654

### Bookmark manager - Adding user accounts - Forgotten password

Instead of implementing it, let's just discuss how it could be done since it's fairly straightforward.

If a user forgets the password, we cannot just send it by email for two reasons. Firstly, we don't know the password: we only have the digest. Secondly, that would be insecure because the password would likely be stored in the email archive. If the email archive is compromised, then the attacker would know the password.

Instead of sending the password, we need to send a one-time password recovery token. It's a long random string that can be used only once and only for a limited time to change the password. The flow is as follows:

*Create a form that can be used to request a new password. The only field you need is email.
*Find the record of the user that's recovering the password.
*Generate a long, random password recovery token and save it as part of the user record, together with a timestamp.
```ruby
user = User.first(:email => email)
# avoid having to memorise ascii codes
user.password_token = (1..64).map{('A'..'Z').to_a.sample}.join
user.password_token_timestamp = Time.now
user.save
```
*Create a route to reset the password: get "/users/reset_password/:token"
*Send an email with this a link containing this token to the user.
*When the link is clicked, find the user that has this token in the database.
```ruby 
user = User.first(:password_token => token)
```
*Check that the token was issued recently (a hour, maybe, or less) and if so, allow the user to set a new password (this will require a new form and a new route to handle it. The token must be a hidden field on the form and it must be checked again after submission. Finally, after the new password is set, remove the token from the database, so that it couldn't be used again.

### Sending the email

To send an email, you will need an external SMTP server that will do it for you. There are several companies provided these services: Mailgun and Sendgrid are among the most popular. They are also available as add-ons on Heroku, making the integration into your application trivial. Let's consider how we could use Mailgun to send emails.

First, you'll need to add the addon to heroku. This will make the API key that you need to send an email available in your env variables (you can read them by typing "heroku config" in the project folder).

Sending the email is as easy as sending a POST request from your app. To send an HTTP request, you'll need one of the many available libraries (HTTParty, Net::HTTP, RestClient, etc). The following example is taken from the Mailgun quickstart guide. It uses RestClient.

```ruby
def send_simple_message
  RestClient.post "https://api:key-3ax6xnjp29jd6fds4gc373sgvjxteol0"\
  "@api.mailgun.net/v2/samples.mailgun.org/messages",
  :from => "Excited User <me@samples.mailgun.org>",
  :to => "bar@example.com, baz@example.com",
  :subject => "Hello",
  :text => "Testing some Mailgun awesomness!"
end
```

To test it locally it may be convenient to add the addon to Heroku to generate and API key and then create an environment variable in your .bash_profile to make it available locally.

## Styling the website

Right now our Bookmark Manager is very basic. Let's make it a bit more beautiful. We could have user powerful frameworks like Twitter Bootstrap that would have made our task easier but for the sake of practicing working with raw HTML/CSS, let's not use them.

Normally, as a developer, you'd get wireframes from a designer or take an off-the-shelf theme but our objective in this lesson is to learn how to write HTML&CSS from scratch.

In this section I will sometimes omit non-essential CSS&HTML examples focusing on more interesting aspects of front-end technologies instead.

As with Ruby code, you're strongly encouraged to use the code provided only as a reference to understand how it works. Write your own HTML and CSS code by hand, googling every new HTML tag and CSS property you encounter.

This is our starting point. There is no styling except the background colour.

![alt text](https://dchtm6r471mui.cloudfront.net/hackpad.com_HrmLraJclly_p.52567_1380200452467_Screen%20Shot%202013-09-26%20at%2014.00.29.png "styling")

First, add a css reset file to your project. You can get one from www.cssreset.com. The goal of this file is to define the look of the elements that we didn't write CSS for. The reason CSS reset is necessary is that every browser uses its own defaults, so if you don't specify some property, your CSS may look slightly different in different browsers.

After we add Eric Meyer's CSS reset, our page looks very different.

![alt text](https://dchtm6r471mui.cloudfront.net/hackpad.com_HrmLraJclly_p.52567_1380201547369_Screen%20Shot%202013-09-26%20at%2014.18.53.png "styling")

## Front page

Let's start by creating a black header line that will have the logo and the sign-in / sign-up / sign-out buttons. We're will be giving most elements an id or class to refer to the in the CSS file. The welcome message is a span because it doesn't need the dimensions, so we can use an inline element.

```ruby
<header>
  <div id="logo">Bookmark Manager</div>
  <div id="user-links">
    <% if current_user %>
      <span id="welcome-message">
        Welcome, <%= current_user.email %>  
      </span>
    
      <form id="sign-out" method="post" action="/sessions">
        <input type="hidden" name="_method" value="delete">
        <input type="submit" value="Sign out">
      </form>
  </div>
</header>
```
![alt text](https://dchtm6r471mui.cloudfront.net/hackpad.com_HrmLraJclly_p.52567_1380201890089_Screen%20Shot%202013-09-26%20at%2014.24.45.png)

github
https://github.com/makersacademy/bookmark_manager/tree/8dde272fc5957bff09d196d6ec56d1278aa0c7c9

Let's now add sign up and sign in buttons.

![alt text](https://dchtm6r471mui.cloudfront.net/hackpad.com_HrmLraJclly_p.52567_1380203189272_Screen%20Shot%202013-09-26%20at%2014.46.12.png)

github
https://github.com/makersacademy/bookmark_manager/tree/c61d9bb8c2516207c1bd16c26c2d4ca367135bfe

Let's add some subtle texture to the background. The Extra Clean Paper on Subtle Patterns looks nice.

![alt text](https://dchtm6r471mui.cloudfront.net/hackpad.com_HrmLraJclly_p.52567_1380204212191_Screen%20Shot%202013-09-26%20at%2015.03.27.png)

github
https://github.com/makersacademy/bookmark_manager/tree/94ff132a390afb6bc9e3bfffeb118f737bb64da9

Let's now extract the form to add a link to its own page. To do this we need to create a new view, /links/new.erb, a new route in links.rb and update the tests that were expecting the form to be on the frontpage.

![alt text](https://dchtm6r471mui.cloudfront.net/hackpad.com_HrmLraJclly_p.52567_1380204564552_Screen%20Shot%202013-09-26%20at%2015.09.19.png)


![alt text](https://dchtm6r471mui.cloudfront.net/hackpad.com_HrmLraJclly_p.52567_1380204584565_Screen%20Shot%202013-09-26%20at%2015.09.39.png)

github
https://github.com/makersacademy/bookmark_manager/tree/3f393ebd1c36c290cc545f7d1c55012aba307c6d

The logo of the website is usually a link to the frontpage. Let's make it a link by wrapping the text in the anchor element. We'll need to update our css to specify that all links in the header are white and have no text-decoration (by default, links are underlined). 

It's also a good time to get rid of the "Welcome to the bookmark manager" message.

Let's now add a button to submit a new link to the header. We already have a route for it, /links/new, so it will simply be a link between #logo and #user-links.
```html
<a href="/links/new" class="button highlighted">Add link</a>
```

This link has two classes, though. It's a button because we want it to look like a button but we give it a different class to override background colour.

```css
/* a link that has both classes. Overrides the previous declaration*/
a.button.highlighted {
  background-color: #b77843;
}
```

Now we have a button that's slightly different from the default button. The space between the logo and the button is explained by the margin-right on the logo.

![alt text](https://dchtm6r471mui.cloudfront.net/hackpad.com_HrmLraJclly_p.52567_1380205383837_Screen%20Shot%202013-09-26%20at%2015.22.58.png)

The colour was chosen using Colorhexa. It can generate colour schemes: sets of colours that arguably go together. If you're can't tell what colours go together (I'm like this), use colour scheme generators.

Note that I added a couple more links to the database.

github
https://github.com/makersacademy/bookmark_manager/tree/7baae00b00b55846c4a4618c337c202523315879

Let's now style the links list. First, let's put them into a container and move the link itself into a partial (remember partials from Sudoku – web version?). This will allow us to style the container itself.
```html
<div id='links-container'>
  <ul id='links'>
    <% @links.each do |link| %>
      <%= partial :link, :locals => {:link => link}  %>
    <% end %>
  </ul>  
</div>
```

Just the white background, margins, padding and a hint of a shadow and it already looks better.

![alt text](https://dchtm6r471mui.cloudfront.net/hackpad.com_HrmLraJclly_p.52567_1380206873619_Screen%20Shot%202013-09-26%20at%2015.47.45.png)

Now let's make the links look better. First, let's create the elements we want to see in the link partial: title, description, time and author. We don't have most of the information yet, so let's use placeholders for now.

```html
<li class='link'>
  <a class='title' href="<%= link.url %>"><%= link.title %></a>
  <div class='description'>
    Lorem ipsum dolor sit amet, consectetur adipisicing elit, sed do eiusmod tempor incididunt ut labore et dolore magna aliqua.
  </div>
  <span class='source'>
    added yesterday by 
    <a href="#">evgeny@makersacademy.com</a>
  </span>
</li>
```

Note that we only use classes in this partial. Since this partial is going to be repeated several times on the page, we can't use any ids because every id is meant to be unique on the page.

Most of the css for this partial is here.

```css
.link {
  background-color: #EEE; /* same as #EEEEEE */
  box-shadow: 0 0 5px rgba(0,0,0,0.4);
  /* 10px for top and bottom, inherit from parent */
  /* for left and right */
  margin: 10px inherit;
  padding: 15px 10px;
}

  .link a.title {
    /* to make it slightly more prominent */
    letter-spacing: 1px;
  }

  .link .description {
    margin: 10px inherit;
  }

  .link .source {
    /* http://learnlayout.com/float.html and the next 4 sections */
    float: right; 
    font-size: 12px;
  }
```

Now our frontpage looks much better.

![alt text](https://dchtm6r471mui.cloudfront.net/hackpad.com_HrmLraJclly_p.52567_1380208869701_Screen%20Shot%202013-09-26%20at%2016.21.03.png)

Note how the use of shadows gives the page depth.

github
https://github.com/makersacademy/bookmark_manager/tree/2aac0e5a09c8a1f2bbaad5eecf774eb0c9494211

Now let's add a footer to the page to give it completeness (and include a reference to Makers Academy in case this bookmark manager becomes really popular).

```html
<footer>
  <div id="makersacademy-logo">
    <a href="http://www.makersacademy.com/">
      <img src="http://www.makersacademy.com/images/logo.png">
    </a>
  </div>
  <div id="technologies">
    <p>
      I built this page at 
      <a href="http://www.makersacademy.com">Makers Academy,
      a highly selective 12 week coding course in London</a>.
    </p>
    <p>
      This website is built using Ruby, Sinatra, 
      RSpec, Capybara, HTML and CSS.
    </p>
  </div>
</footer>
```

Let's style it using display="flex", as we've done in the header.
```css
footer {
  display: flex;
  background-color: rgba(0,0,0,0.2);
}

  footer > * {
    margin: auto inherit;
  }

  footer img {
    /* http://stackoverflow.com/questions/10658475/3px-extra-height-on-a-div-with-an-image-inside-it */
    vertical-align: top;
  }

  footer #technologies {
    -webkit-flex: 1;
    flex: 1;
  }

  footer p {
    padding: 5px 25px;
  }
  ```


This produces the following effect.

![alt text](https://dchtm6r471mui.cloudfront.net/hackpad.com_HrmLraJclly_p.52567_1380216944437_Screen%20Shot%202013-09-26%20at%2018.33.15.png)

The footer is not "sticky", that is, if the window is larger than the content available, then the footer will not be at the bottom of the page.

![alt text](https://dchtm6r471mui.cloudfront.net/hackpad.com_HrmLraJclly_p.52567_1380217103005_Screen%20Shot%202013-09-26%20at%2018.38.15.png)

There are various techniques of making the footer "sticky". Feel free to try this one.

github
https://github.com/makersacademy/bookmark_manager/tree/27a54fced01e6c140d9040340c11e12709c57635

Let's now get back to the header and write some CSS for the case when the user is logged in because right now it's not very pretty.

![alt text](https://dchtm6r471mui.cloudfront.net/hackpad.com_HrmLraJclly_p.52567_1380217495035_Screen%20Shot%202013-09-26%20at%2018.44.07.png)

The first step would be to give all children of #user-links the display: inline-block property. The second step would be to replace the default button with a beautiful button. Just add the class "button" and update the CSS because right now all relevant CSS declarations only apply to links with the class button, whereas we have an input element in the form. Also, we'll need to explicitely set font-size: 16px for the "button" class.

However, we've just got an unexpected problem. Because the box model for a link and an input element differ, setting the width of 80px for the button class produces different results. A good solution would be to set the same box model rules for all elements, as we discussed in HTML & CSS. We should have done it at the very beginning but it's not too late to change the rules. Let's set it now:

```css
* {
  box-sizing: border-box;
}
```

Now the same box model is used for all elements. Since now the width property takes into account borders and padding, we'll need to increase it for the button class.

```css
width: 110px;
```

This finally produces a nice result: the input element looks exactly like a button.

![alt text](https://dchtm6r471mui.cloudfront.net/hackpad.com_HrmLraJclly_p.52567_1380218599377_Screen%20Shot%202013-09-26%20at%2019.02.51.png)

One last change to the header, though. When you hover over links, the cursor looks like a hand, whereas if you hover over an input element, it looks like an arrow. It's easy to fix by forcing the cursor we need for the button class.

```css
cursor: pointer; /* pointer looks like a hand */
```

github
https://github.com/makersacademy/bookmark_manager/tree/9c854827b174fa962a5c06df70bf8234c2bc81d3

Finally, let's style the flash message. At the moment it's not styled at all, it just appears as text:


![alt text](https://dchtm6r471mui.cloudfront.net/hackpad.com_HrmLraJclly_p.52567_1380219002454_Screen%20Shot%202013-09-26%20at%2019.09.57.png)

Let's make it beatiful. A few trivial changes produce a better flash notice.

```css
#notice {
  text-align: center;
  margin: 5px;
  padding: 5px;
  background-color: rgba(67,183,120,0.75);
  border-radius: 4px;
  box-shadow: 0 0 3px rgba(0,0,0,0.4);
  color: white;
}
```

![alt text](https://dchtm6r471mui.cloudfront.net/hackpad.com_HrmLraJclly_p.52567_1380219458030_Screen%20Shot%202013-09-26%20at%2019.17.30.png)

Now our frontpage looks slightly more sophisticated than when we started (even though a professional designer would not be particularly impressed by what we've done).

github
https://github.com/makersacademy/bookmark_manager/tree/83af49077d34aa9e1d39673df689ab1daef2d73d

Let's style other pages in the same way. The process is mostly mechanical, so let's highlight only the most interesting points.

Firstly, let's make the #links-container element part of the layout, so that it was the basis of every page. Since it's not a links container anymore, we'll rename it as well. This change will not lead to any change in the way the frontpage looks, so no screenshot here.

github
https://github.com/makersacademy/bookmark_manager/tree/cc1cbffa1314f36021293376e6eae5404ec1dc8e

Now let's make the /links/new view look better. Note that we're using placeholders (text inside the input that disappears on focus) instead of labels.
```html
<input type="text" name="url" placeholder="Url">
```

![alt text](https://dchtm6r471mui.cloudfront.net/hackpad.com_HrmLraJclly_p.52567_1380271885168_Screen%20Shot%202013-09-27%20at%2009.51.17.png)

github
https://github.com/makersacademy/bookmark_manager/tree/eb68cf41e0bc204365a142fa3520141574a241a2

Let's do the same to the sign up and sign in forms, not forgetting the flash for the form. Since we can potentially show more than one error or notice, let's switch to using classes instead of ids.

```html
<% if flash[:notice] %>
  <div class='flash notice'>
    <%= flash[:notice] %>
  </div>
<% end %>
<% if flash[:errors] && !flash[:errors].empty? %>  
  <ul>
    <% flash[:errors].each do |error| %>
      <li class='flash error'><%= error %></li>
    <% end %>
  </ul>
<% end %>
```

![alt text](https://dchtm6r471mui.cloudfront.net/hackpad.com_HrmLraJclly_p.52567_1380275191987_Screen%20Shot%202013-09-27%20at%2010.36.20.png)

![alt text](https://dchtm6r471mui.cloudfront.net/hackpad.com_HrmLraJclly_p.52567_1380275196397_Screen%20Shot%202013-09-27%20at%2010.46.17.png)

github
https://github.com/makersacademy/bookmark_manager/tree/0a78ed38cc17b197fc91ee999ab14a4a72090045

Now let's make the footer sticky using the technique described by Ryan Fait. One aspect of this technique is that it requires the footer to have a fixed height, so let's fix it at 70px (the height of the image and reduce the font-size to 12px. This will produce a weird side-effect on narrow screens (try resizing the window) but let's learn how to deal with it later, when we'll be discussing responsive design.

By applying Ryan's CSS directly, we achieve the desired effect with minimal changes to our layout.

```html
<body>
  <div class="wrapper">
    <%= partial :header %>
    <%= partial :flash %>
    <div id='container'>
      <%= yield %>
    </div>
    <div class="push"></div>
  </div>
  <div class="footer">
    <%= partial :footer %>
  </div>
</body>
```

![alt text](https://dchtm6r471mui.cloudfront.net/hackpad.com_HrmLraJclly_p.52567_1380276377318_Screen%20Shot%202013-09-27%20at%2011.06.12.png)

github
https://github.com/makersacademy/bookmark_manager/tree/10f47e97815b73dc0d75dcbb4eb9a79686f9576f

We will add more advanced functionality using Javascript and more advanced HTML&CSS techniques next week. If you haven't done so yet, it's a good time to deploy your website to Heroku.



## Exercises

By now you should be able to do all of the following (in no particular order).

* Show the list of available tags on the homepage
* Move the form to add a link to its own route
* Add user_id to tags and links. Display who the link was submitted by. Same for a tag
* Allow the user to add a link to favourites (this will be a many-to-many relationship)
* Display how many users favourited the link
* Create a user profile page that will show the links they submitted, tags they created and their favourites.
* Display the link to the user's profile at the top of the page if the user is logged in
* Implement forgotten password functionality
* Redirect the user with a flash message if a logged in user tries to sign up or sign in
* Send a welcome email when the user signs up
* Create validations for all models:
* email must have the correct format (see an example in Datamapper Validations)
* email and password must be present
* link must have a title and a url
* tag must have some text
* Add a description property to the link.
* Add a username to the User model, so that username instead of an email was shown next to the link.
