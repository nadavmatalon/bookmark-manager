get "/" do
	@links = Link.all
	@links = @links.sort_by { |title| title[:title] }
	@filtered_list = false
  	erb :index
end