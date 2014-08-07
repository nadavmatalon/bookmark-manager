require "data_mapper"

class Tag

	include DataMapper::Resource

	has n, :links, through: Resource

	property :id, Serial
	property :text, String

	validates_uniqueness_of :text
end

