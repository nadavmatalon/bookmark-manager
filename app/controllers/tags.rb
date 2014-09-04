get "/tags/" do
	redirect to("/")
end

get "/tags/:text" do
		tag_name = params[:text].capitalize
		tag_name = tag_name.gsub!('_', ' ') if tag_name.include?('_')
		tag = Tag.all.select {|tag| tag.text == tag_name}.first
		@links = tag ? tag.links : []
		@links = @links.sort_by { |title| title[:title] }
		@filtered_list = true
		@selected_tag = tag[:text]
		erb :index
end
