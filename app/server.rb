require "sinatra"
require "data_mapper"
require "rack-flash"
require "./lib/link"
require "./lib/tag"
require "./lib/user"

env = ENV["RACK_ENV"] || "development"
DataMapper.setup(:default, ENV['DATABASE_URL'] || "postgres://localhost/bookmark_manager_#{env}")
DataMapper.finalize
# DataMapper.auto_upgrade!

use Rack::Flash

set :views, Proc.new {File.join(root, '..', "views")}
set :public_folder, Proc.new {File.join(root, '..', "public")}

enable :sessions

set :session_secret, "information"

get "/" do
	@links = Link.all
	@links = @links.sort_by { |title| title[:title] }
	@filtered_list = false
  erb :index
end

post "/links" do
	url = params["url"]
	title = params["title"]
	tags = params["tags"].split(",").map do |tag|
		tag[0] = '' if tag[0] == ' '
		if tag != ''
			tag.capitalize!
			Tag.first_or_create(text: tag)
		end
	end
	title.capitalize! if title[0] == title[0].downcase
	Link.create(url: url, title: title, tags: tags)
	redirect to("/")
end

get "/tags/:text" do
		tag = Tag.first(text: params[:text])
		@links = tag ? tag.links : []
		@links = @links.sort_by { |title| title[:title] }
		@filtered_list = true
		@selected_tag = tag[:text]
		erb :index
end

get "/tags/" do
	redirect to("/")
end

get "/users/new" do
	@user = User.new
	erb :"/users/new"
end

post "/users" do
	@user = User.new(email: params[:email], password: params[:password],
					password_confirmation: params[:password_confirmation])
	if @user.save
		session[:user_id] = @user.id
		redirect to("/")
	else
		flash.now[:errors] = @user.errors.full_messages
		erb :"users/new"
	end
end

get "/sessions/new" do
	erb :"sessions/new"
end

delete "/sessions" do
	flash[:notice] = "Bye for now #{current_user.email}, thanks for visiting!"
	session[:user_id] = nil
	redirect to("/")
end

post '/sessions' do
	email, password = params[:email], params[:password]
	user = User.authenticate(email, password)
  	if user
  		flash[:errors] = []
    	session[:user_id] = user.id
    	redirect to('/')
  	else
    	flash[:errors] = ["The email or password is incorrect"]
    	erb :"sessions/new"
  	end
end

def current_user    
	@current_user ||=User.get(session[:user_id]) if session[:user_id]
end

