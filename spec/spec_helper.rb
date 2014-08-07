ENV["RACK_ENV"] = "test"

require "./app/server.rb"
require "./lib/link.rb"
require "./lib/tag.rb"
require "./lib/user.rb"
require "database_cleaner"
require "capybara/rspec"
require "rack-flash"
require "debugger"
require "launchy"

Capybara.app = Sinatra::Application.new

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

def create_tag(text="tag")
	Tag.create(text: text)
end

def create_link(title="title", url="http://www.example.com", 
				tags=[create_tag("tag_one"),
					  create_tag("tag_two")])
	link = Link.create(title: title, url: url, tags: tags)
end

def add_link(url, title, tags = [])
	sign_up
	visit "/"
	within('#new-link') do
		fill_in 'url', :with => url
		fill_in 'title', :with => title
		fill_in 'tags', :with => tags.join(' ')
		click_button 'Add link'
	end
end

def register_user
	sign_up
	sign_out
end

def sign_up(email = "test@example.com", password = "password", 
			password_confirmation = "password")
	visit "/"
	click_link "Sign up"
	fill_in :email, with: email
	fill_in :password, with: password
	fill_in :password_confirmation, with: password_confirmation
	click_button "Register"
end

def sign_in(email = "test@example.com", password = "password")
	visit "/sessions/new"
	fill_in "email", with: email
	fill_in "password", with: password
	click_button "Sign In"
end

def sign_out
	visit "/"
	click_button "Sign out"
end

