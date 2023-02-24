require 'pathname'
require 'csv'

class DataPackBase
	attr_reader :media_root, :data_root

	def initialize(source)
		@media_root = Entry.path("#{source}/media/catalog/product")
		@data_root = Entry.path("#{source}/data/")
	end
end
