class ProductContent < DataPackBase
	attr_reader :data_roots, :filename, :headers

	def initialize(source)
		super(source)
		@filename = 'products.csv'
		@headers = %w[
			sku
			product_websites
			product_type
			name
			categories
			base_image
			small_image
			thumbnail_image
			swatch_image
			additional_images
			additional_attributes
			qty
			visibility
			configurable_variations
		]
		@images =
			Dir
				.glob(File.join(@media_root, '**', '*.png'))
				.each_with_object([]) { |path, arr| arr << path }
	end

	def files_to_rows
		@images
			.map { |file| File.basename(file).split('-') }
			.group_by { |row| row[1] }
			.sort
			.reverse
			.flat_map { |v| v[1].sort }
	end

	def simple_skus
		files_to_rows.select { |row| row[1] == 'simple' && row[3].include?('main') }
	end

	def configurable_skus
		files_to_rows.select do |row|
			row[1] == 'configurable' && row[3].include?('main')
		end
	end

	def unique_skus
		simple_skus + configurable_skus
	end

	def format_name(name)
		return name.split('_').map(&:capitalize).join(' ') if name.include?('_')
		name.capitalize()
	end

	def build_images(row)
		files_to_rows
			.group_by { |r| r[0] == row[0] }
			.each_with_object([]) do |(key, item), arr|
				arr << item.map { |row| row.join('-') }.flatten if key == true
			end
			.first
	end

	def main_image(images_arr)
		images_arr.find { |image| image.include?('main') }
	end

	def additional_images(images_arr)
		images_arr.reject { |image| image.include?('main') }.join(', ')
	end

	def which_configurable?(row)
		configurable_skus.select do |configurable_row|
			row[1] == 'simple' && row[0].include?(configurable_row[0])
		end.flatten
	end

	def additional_attributes(row)
		data =
			files_to_rows
				.group_by { |file_row| file_row[0] == row[0] }
				.select { |k, v| k == true }
				.flat_map { |_k, v| v }
				.select { |row| row.include?('main') }
				.map do |row|
					row
						.select { |item| item.include?('|') }
						.flat_map { |row| row.gsub('.png', '').split('|').join('=') }
						.join(',')
				end
				.join('')

		return '' if data.empty?

		data
	end

	def build_qty(row)
		return '' if row[1] == 'configurable'
		'1000'
	end

	def build_visibility(row)
		return 'Not Visible Individually' unless which_configurable?(row).empty?

		'Catalog and Search'
	end

	def build_variations(row)
		return '' if row[1] == 'simple'

		simples =
			simple_skus.each_with_object([]) do |simple_row, arr|
				arr << simple_row if simple_row[0].include?(row[0])
			end

		simples
			.each_with_object([]) do |row, arr|
				arr << "sku=#{row[0]},#{additional_attributes(row)}"
			end
			.join('|')
	end

	def assemble
		unique_skus.each_with_object([]) do |row, arr|
			arr << [
				row[0],
				'base',
				row[1],
				format_name(row[2]),
				'Default Category',
				main_image(build_images(row)),
				main_image(build_images(row)),
				main_image(build_images(row)),
				main_image(build_images(row)),
				additional_images(build_images(row)),
				additional_attributes(row),
				build_qty(row),
				build_visibility(row),
				build_variations(row),
			]
		end
	end
end
