require 'pathname'

class Entry
	@entries_to_remove = %w[. .. .DS_Store .gitignore .git .vscode]

	def Entry.path(path_str)
		Pathname(File.join(path_str))
	end

	def Entry.last_slug(path_arr)
		path_arr.split('/').last
	end

	def Entry.files_from(file_path)
		return nil unless File.exist?(path(file_path))

		Dir.entries(file_path) - @entries_to_remove
	end

	def Entry.filename_contains?(file_arr, str_pattern)
		file_arr.select { |file| file.include?(str_pattern) }.any?
	end
end
