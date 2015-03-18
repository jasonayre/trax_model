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
    t.string   "email_address"
    t.string  "subdomain"
    t.string  "website"
    t.integer  "status"
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
    t.datetime "created_at",        :null => false
    t.datetime "updated_at",        :null => false
  end

  create_table "staplers", :force => true do |t|
    t.string "name"
    t.string "type"
    t.integer "attribute_set_id"
    t.datetime "created_at",        :null => false
    t.datetime "updated_at",        :null => false
  end

  create_table "swingline_stapler_attribute_sets", :force => true do |t|
    t.float "speed"
    t.string "owner"

    t.datetime "created_at",        :null => false
    t.datetime "updated_at",        :null => false
  end
end

class Product < ::ActiveRecord::Base
  include ::Trax::Model
  include ::Trax::Model::UniqueId

  defaults :uuid_prefix => "1a", :uuid_column => "uuid"
end

class Widget < ::ActiveRecord::Base
  include ::Trax::Model

  defaults :uuid_prefix => "2a", :uuid_column => "uuid"

  validates :subdomain, :subdomain => true, :allow_nil => true
  validates :email_address, :email => true, :allow_nil => true
  validates :website, :url => true, :allow_nil => true
end

class Message < ::ActiveRecord::Base
  include ::Trax::Model

  defaults :uuid_prefix => "3a", :uuid_column => "uuid"

  mixins :freezable => true,
         :restorable => { :field => :deleted }

  enum :status => [:queued, :scheduled, :delivered, :failed_delivery]

  default_value_for :status do
    self.statuses[:queued]
  end

  validates :deliver_at, :future => true, :allow_nil => true

  freezable_by_enum :status => [ :delivered, :failed_delivery ]
end

class Thing < ::ActiveRecord::Base
  include ::Trax::Model

  defaults :uuid_prefix => "4a", :uuid_column => "uuid"
end

class Person < ::ActiveRecord::Base
  include ::Trax::Model

  defaults :uuid_column => "uuid"
end

class Stapler < ::ActiveRecord::Base
  include ::Trax::Model
end

class SwinglineStapler < ::Stapler
  include ::Trax::Model::STI::Attributes
end

class SwinglineStaplerAttributeSet < ::ActiveRecord::Base
end
