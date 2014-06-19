require "data_mapper"

class Link

	include DataMapper::Resource

	has n, :tags, :through => Resource

	property :id,     Serial  #this automatically creates a unique key for each line
	property :title,  String
	property :url,    String
end


