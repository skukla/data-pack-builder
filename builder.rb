require_relative './lib/data_pack_base.rb'
require_relative './lib/product_content.rb'
require_relative './lib/product_attribute_content.rb'
require_relative './lib/csv_writer.rb'
require_relative './lib/entry.rb'

source = 'data-pack'

product_attribute_content = ProductAttributesContent.new(source)
product_content = ProductContent.new(source)

data_content = [product_attribute_content, product_content]

data_content.each { |file| CSVWriter.new(file).write }