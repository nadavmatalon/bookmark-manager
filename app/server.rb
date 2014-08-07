require "sinatra"
require "data_mapper"
require "rack-flash"
require "./lib/link"
require "./lib/tag"
require "./lib/user"

require_relative "controllers/application"
require_relative "controllers/links"
require_relative "controllers/tags"
require_relative "controllers/users"
require_relative "controllers/sessions"

require_relative 'helpers/application'

env = ENV["RACK_ENV"] || "development"
DataMapper.setup(:default, ENV['DATABASE_URL'] || "postgres://localhost/bookmark_manager_#{env}")
DataMapper.finalize
# DataMapper.auto_upgrade!

use Rack::Flash

set :views, Proc.new {File.join(root, '..', "views")}
set :public_folder, Proc.new {File.join(root, '..', "public")}

enable :sessions

set :session_secret, "information"

