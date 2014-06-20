require "sinatra"
require "data_mapper"
require "rack-flash"
require "./lib/link"
require "./lib/tag"
require "./lib/user"

env = ENV["RACK_ENV"] || "development"
DataMapper.setup(:default, "postgres://localhost/bookmark_manager_#{env}")
DataMapper.finalize
# DataMapper.auto_upgrade!

use Rack::Flash

set :views, Proc.new {File.join(root, '..', "views")}
set :public_folder, Proc.new {File.join(root, '..', "public")}

enable :sessions

set :session_secret, "information"


get "/" do
	@links = Link.all
  erb :index
end

post "/links" do
	url = params["url"]
	title = params["title"]
	tags = params["tags"].split(" ").map do |tag|
		Tag.first_or_create(:text => tag)
	end
	Link.create(:url => url, :title => title, :tags => tags)
	redirect to("/")
end

get "/tags/:text" do
	tag = Tag.first(:text => params[:text])
	@links = tag ? tag.links : []
	erb :index
end

get "/new_user" do
	@user = User.new
	erb :new_user
end

post "/users" do
	@user = User.new(:email => params[:email], :password => params[:password],
					:password_confirmation => params[:password_confirmation])
	if @user.save
		session[:user_id] = @user.id
		redirect to("/")
	else
		flash.now[:errors] = @user.errors.full_messages
		erb :new_user
	end
end



def current_user    
	@current_user ||=User.get(session[:user_id]) if session[:user_id]
end

