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
require "helpers/session.rb"

include SessionHelpers

Capybara.app = Sinatra::Application.new

RSpec.configure do |config|

	config.treat_symbols_as_metadata_keys_with_true_values = true

  	config.order = 'random'

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

