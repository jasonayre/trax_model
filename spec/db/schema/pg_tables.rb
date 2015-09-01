PG_TABLES = Proc.new do
  create_table "ecom_products", :force => true do |t|
    t.string   "name"
    t.integer  "category_id"
    t.integer  "user_id"
    t.decimal  "price"
    t.integer  "in_stock_quantity"
    t.integer  "on_order_quantity"
    t.boolean  "active"
    t.string   "uuid"
    t.integer  "status"
    t.integer  "size"
    t.jsonb    "custom_fields"
    t.datetime "created_at",        :null => false
    t.datetime "updated_at",        :null => false
  end
end
