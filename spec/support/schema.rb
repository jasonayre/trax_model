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

  create_table "organizations", :force => true do |t|
    t.string   "subdomain"
    t.integer  "status"
    t.string   "uuid"
    t.datetime "created_at",        :null => false
    t.datetime "updated_at",        :null => false
  end

  create_table "messages", :force => true do |t|
    t.string   "subject"
    t.integer  "status"
    t.string   "uuid"
    t.datetime "created_at",        :null => false
    t.datetime "updated_at",        :null => false
  end
end

class Product < ::ActiveRecord::Base
  include ::Trax::Model

  defaults :uuid_prefix => "a1", :uuid_column => "uuid"
end

class Organization < ::ActiveRecord::Base
  include ::Trax::Model

  defaults :uuid_prefix => "a2", :uuid_column => "uuid"

  validate :subdomain, :subdomain => true

  ### Enums ###
  enum :status => [:queued, :scheduled, :delivered, :delivery_failed] unless instance_methods.include? :status
end

class Message < ::ActiveRecord::Base
  include ::Trax::Model
  include ::Trax::Model::Freezable

  defaults :uuid_prefix => "a3", :uuid_column => "uuid"

  enum :status => [:queued, :scheduled, :delivered, :failed_delivery]

  default_value_for :status do
    self.statuses[:queued]
  end

  freezable_by_enum :status => [:delivered, :failed_delivery]
end
