class ProductAttributesContent < DataPackBase
	attr_reader :data_roots, :filename, :headers

	def initialize(source)
		super(source)
		@source = source
		@filename = 'product_attributes.csv'
		@headers = %w[
			attribute_set
			attribute_code
			frontend_label
			frontend_input
			option
			default
			default_value_text
			default_value_yesno
			default_value_date
			default_value_textarea
			is_global
			is_filterable
			is_filterable_in_search
			is_searchable
			is_visible_in_advanced_search
			is_comparable
			is_used_for_promo_rules
			is_html_allowed_on_front
			is_visible_on_front
			is_required
			is_unique
			used_in_product_listing
			used_for_sort_by
			position
			additional_data
		]
	end

	def build_attribute_hash(attributes, hash)
		attributes.each do |row|
			pair = row.split('=')
			if hash.key?(pair[0])
				hash[pair[0]] << pair[1]
			else
				hash[pair[0]] = [pair[1]]
			end
		end
		hash
	end

	def gather_attributes
		products = ProductContent.new(@source)
		products
			.unique_skus
			.map { |row| products.additional_attributes(row) }
			.reject(&:empty?)
			.uniq
			.map { |row| row.split(',') }
			.reduce({}) { |hash, attributes| build_attribute_hash(attributes, hash) }
	end

	def assemble
		gather_attributes.each_with_object([]) do |(attribute, values), rows|
			rows << [
				'Default',
				attribute,
				attribute.capitalize,
				'select',
				values.join("\n"),
				'',
				'',
				'',
				'',
				'',
				'',
				'1',
				'1',
				'1',
				'1',
				'1',
				'1',
				'1',
				'1',
				'0',
				'0',
				'0',
				'0',
				'',
				'',
			]
		end
	end
end
