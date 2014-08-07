get "/tags/" do
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
