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
    t.jsonb    "related_product_ids"
    t.datetime "created_at",        :null => false
    t.datetime "updated_at",        :null => false
  end

  create_table "ecommerce_votes", :id => :uuid, :force => true do |t|
    t.uuid "voteable_id"
    t.jsonb "upvoter_ids"
    t.jsonb "downvoter_ids"
    t.jsonb "upvoter_ids_array"
    t.jsonb "downvoter_ids_array"
    t.datetime "created_at",        :null => false
    t.datetime "updated_at",        :null => false
  end

  create_table "ecommerce_users", :id => :uuid, :force => true do |t|
    t.string "name"
    t.text "watched_product_ids", :array => true
    t.jsonb "locales"
    t.jsonb "sign_in_locations"
    t.jsonb "shopping_cart_sessions"
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
