require 'pathname'
require 'csv'

class CSVWriter
	def initialize(file_obj)
		@headers = file_obj.headers
		@content = file_obj.assemble
		@filename = file_obj.filename
		@file_path = File.join(file_obj.data_root, @filename)
	end

	def write
		print "Writing #{@filename} to #{@file_path}..."
		
		CSV.open(
			@file_path,
			'wb',
			write_headers: true,
			headers: @headers,
			quote_empty: true,
		) { |csv| @content.each { |row| csv << row } }

		print "done.\n"
	end
end
