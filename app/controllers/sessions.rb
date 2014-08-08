get "/sessions/new" do
	erb :"sessions/new", layout: !request.xhr?
end

delete "/sessions" do
	flash[:notice] = "Bye for now #{current_user.email}, thanks for visiting!"
	session[:user_id] = nil
  erb :index

end

post '/sessions' do
	email, password = params[:email], params[:password]
	user = User.authenticate(email, password)
  	if user
  		flash[:errors] = []
    	session[:user_id] = user.id
      erb :index
  	else
    	flash[:errors] = ["email or password are incorrect"]
    	erb :"sessions/new"
  	end
end

