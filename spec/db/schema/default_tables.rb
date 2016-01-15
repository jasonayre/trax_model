DEFAULT_TABLES = Proc.new do
  create_table "subscribers", :force => true do |t|
    t.string   "name"
    t.string   "uuid"
    t.datetime "created_at",        :null => false
    t.datetime "updated_at",        :null => false
  end

  create_table "manufacturers", :force => true do |t|
    t.string   "name"
    t.string   "url"
    t.string   "uuid"
    t.integer  "subscriber_id"
    t.datetime "created_at",        :null => false
    t.datetime "updated_at",        :null => false
  end

  create_table "vehicles", :force => true do |t|
    t.string   "name"
    t.string   "type"
    t.integer  "kind"
    t.integer  "make"
    t.integer  "model"
    t.string   "uuid"
    t.integer  "cost"
    t.integer  "manufacturer_id"
    t.datetime "created_at",        :null => false
    t.datetime "updated_at",        :null => false
  end
  create_table "products", :force => true do |t|
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
    t.datetime "created_at",        :null => false
    t.datetime "updated_at",        :null => false
  end

  create_table "messages", :force => true do |t|
    t.string   "title"
    t.text     "body"
    t.integer  "status"
    t.string   "uuid"
    t.boolean  "deleted"
    t.datetime "deleted_at"
    t.datetime "deliver_at"
    t.datetime "created_at",        :null => false
    t.datetime "updated_at",        :null => false
  end

  create_table "widgets", :force => true do |t|
    t.string "uuid"
    t.string  "email_address"
    t.string  "subdomain"
    t.string  "website"
    t.integer  "status"
    t.integer  "subscriber_id"
    t.string   "name"
    t.datetime "created_at",        :null => false
    t.datetime "updated_at",        :null => false
  end

  create_table "things", :force => true do |t|
    t.string "name"
    t.string "uuid"
    t.datetime "created_at",        :null => false
    t.datetime "updated_at",        :null => false
  end

  create_table "people", :force => true do |t|
    t.string "name"
    t.string "uuid"
    t.integer "vehicle_id"
    t.datetime "created_at",        :null => false
    t.datetime "updated_at",        :null => false
  end

  create_table "users", :force => true do |t|
    t.string "name"
    t.string "uuid"
    t.integer "role"
    t.integer "subscriber_id"
    t.datetime "created_at",        :null => false
    t.datetime "updated_at",        :null => false
  end
end
