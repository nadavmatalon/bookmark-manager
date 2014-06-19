require "sinatra"
require "data_mapper"
require "./lib/link"
require "./lib/tag"
require "./lib/user"

set :views, Proc.new {File.join(root, '..', "views")}
set :public_folder, Proc.new {File.join(root, '..', "public")}

env = ENV["RACK_ENV"] || "development"

DataMapper.setup(:default, "postgres://localhost/bookmark_manager_#{env}")

require "./lib/link.rb"

DataMapper.finalize

DataMapper.auto_upgrade!


enable :sessions

get '/' do
  erb :index
end



