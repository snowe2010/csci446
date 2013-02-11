class Album
	include DataMapper::Resource

	property :id, Serial
	property :rank, Integer
	property :title, String
	property :year, Integer
end
