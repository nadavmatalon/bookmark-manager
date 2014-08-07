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

