require "sinatra"
require 'sinatra/partial'
require "data_mapper"
require "rack-flash"

require_relative "models/link"
require_relative "models/tag"
require_relative "models/user"

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

set :partial_template_engine, :erb

