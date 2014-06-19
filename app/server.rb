require "sinatra"
require "data_mapper"
require "./lib/link"
require "./lib/tag"
require "./lib/user"

set :views, Proc.new {File.join(root, '..', "views")}
set :public, Proc.new {File.join(root, '..', "public")}

enable :sessions

get '/' do
  erb :index
end