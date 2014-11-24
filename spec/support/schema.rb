require 'active_record'

ActiveRecord::Base.establish_connection(
  :adapter => "sqlite3",
  :database => "spec/test.db"
)

ActiveRecord::Base.connection.tables.each do |table|
  ActiveRecord::Base.connection.drop_table(table)
end

ActiveRecord::Schema.define(:version => 1) do
  create_table "products", :force => true do |t|
    t.string   "name"
    t.integer  "category_id"
    t.integer  "user_id"
    t.decimal  "price"
    t.integer  "in_stock_quantity"
    t.integer  "on_order_quantity"
    t.boolean  "active"
    t.string   "uuid"
    t.datetime "created_at",        :null => false
    t.datetime "updated_at",        :null => false
  end
end

class Product < ::ActiveRecord::Base
  include ::Trax::Model

  self.uuid_prefix = "a1"
  self.uuid_column = "uuid"
end
