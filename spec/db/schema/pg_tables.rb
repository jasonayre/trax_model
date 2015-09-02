PG_TABLES = Proc.new do
  execute %q{CREATE EXTENSION IF NOT EXISTS "uuid-ossp";}
  execute %q{CREATE EXTENSION IF NOT EXISTS "pg_trgm";}

  create_table "ecommerce_products", :id => :uuid, :force => true do |t|
    t.string   "name"
    t.string   "type"
    t.uuid     "category_id"
    t.uuid     "user_id"
    t.decimal  "price"
    t.boolean  "active"
    t.integer  "status"
    t.jsonb    "custom_fields"
    t.jsonb    "stock"
    t.datetime "created_at",        :null => false
    t.datetime "updated_at",        :null => false
  end

  create_table "ecommerce_product_attribute_sets", :id => :uuid, :force => true do |t|
    t.uuid     "user_id"
    t.uuid     "product_id"
    t.string   "type"
    t.jsonb    "specifics"
    t.datetime "created_at",        :null => false
    t.datetime "updated_at",        :null => false
  end
end
