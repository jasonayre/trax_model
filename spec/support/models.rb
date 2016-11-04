require 'active_record'
require 'trax_core'

::ActiveRecord::Schema.define(:version => 1) do
  require_relative '../db/schema/default_tables'
  instance_eval(&DEFAULT_TABLES)

  if ENV["DB"] == "postgres"
    require_relative '../db/schema/pg_tables'
    instance_eval(&PG_TABLES)
  end
end

if ENV["DB"] == "postgres"
  require_relative 'pg/models'
end

class Product < ::ActiveRecord::Base
  include ::Trax::Model
  include ::Trax::Model::Attributes::Dsl

  mixins :unique_id => { :uuid_column => "uuid", :uuid_prefix => "1a" },
         :sort_scopes => true,
         :cached_methods => true

  sort_scope :name
  sort_scope :in_stock_quantity, :as => :quantity_in_stock
  sort_scope :on_order_quantity, :as => :quantity_out_of_stock

  class_attribute :inventory_cost, :instance_writer => false
  self.inventory_cost = 0
  cached_class_method(:inventory_cost, :expires_in => 20.minutes)

  def self.in_stock_quantities(_ids=[])
    by_id(*_ids).sum(:in_stock_quantity)
  end
  cached_class_method(:in_stock_quantities, :expires_in => 20.minutes)

  def self.in_stock_quantities_splat(*_ids)
    by_id(*_ids).sum(:in_stock_quantity)
  end
  cached_class_method(:in_stock_quantities_splat, :expires_in => 20.minutes)

  def self.in_stock_quantities_keywords(ids:[])
    by_id(*ids).sum(:in_stock_quantity)
  end
  cached_class_method(:in_stock_quantities_keywords, :expires_in => 20.minutes)

  def some_cached_instance_method
    self.class.inventory_cost
  end
  cached_instance_method(:some_cached_instance_method, :expires_in => 20.minutes)

  mixins :field_scopes => {
    :by_id => true
  }

  belongs_to :category

  define_attributes do
    string :name
    integer :in_stock_quantity
    integer :on_order_quantity

    enum :status, :default => :in_stock do
      define :in_stock,     1
      define :out_of_stock, 2
      define :backordered,  3
    end

    boolean :active, :default => false
  end
end

class Category < ::ActiveRecord::Base
  include ::Trax::Model
  include ::Trax::Model::Attributes::Dsl

  mixins :sort_scopes => true

  has_many :products

  sort_scope :name
  sort_scope :in_stock_quantity, :as => :most_in_stock, :class_name => "Product", :with => :with_products
  sort_scope :on_order_quantity, :as => :least_oversold, :class_name => "Product", :with => :with_products

  scope :with_products, lambda{
    includes(:products).references(:products)
  }
end

module Products
  class Shoes < Product
    include ::Trax::Model
    include ::Trax::Model::Attributes::Dsl
  end

  class MensShoes < Shoes
    include ::Trax::Model
    include ::Trax::Model::Attributes::Dsl

    define_attributes do
      enum :size, :default => :mens_9 do
        define :mens_6,  1
        define :mens_7,  2
        define :mens_8,  3
        define :mens_9,  4
        define :mens_10, 5
        define :mens_11, 6
        define :mens_12, 7
      end

      integer :in_stock_quantity, :default => 0

      scope :by_above_average_size, lambda{
        fields[:size].in(:mens_10, :mens_11, :mens_12)
      }

      scope :by_quantity_in_stock, lambda{ |value|
        fields[:in_stock_quantity].eq(value)
      }
    end
  end
end

class Subscriber < ::ActiveRecord::Base
  include ::Trax::Model
  include ::Trax::Model::Attributes::Dsl

  mixins :unique_id => { :uuid_column => "uuid", :uuid_prefix => "4f" },
         :cached_find_by => true,
         :cached_relations => true

  has_many :manufacturers, :class_name => "Manufacturer"
  cached_has_many :manufacturers

  has_one :admin_user, -> { by_role(:admin) }, :class_name => "User", :foreign_key => :subscriber_id
  cached_has_one :admin_user
  has_one :widget
  cached_has_one :widget
end

class Manufacturer < ::ActiveRecord::Base
  include ::Trax::Model
  include ::Trax::Model::Attributes::Dsl

  mixins :unique_id => { :uuid_column => "uuid", :uuid_prefix => "3d" },
         :cached_find_by => true,
         :cached_relations => true

  has_many :vehicles
  def cached_vehicles
    ::Vehicle.cached_where(:manufacturer_id => self.id)
  end

  belongs_to :subscriber
  cached_belongs_to :subscriber
end

class Vehicle < ::ActiveRecord::Base
  include ::Trax::Model
  include ::Trax::Model::Attributes::Dsl

  mixins :unique_id => { :uuid_column => "uuid", :uuid_prefix => "9c" },
         :sti_enum  => true,
         :cached_find_by => true


  define_attributes do
    enum :kind do
      define :car, 1, :type => "Vehicle::Car"
      define :truck, 2, :type => "Vehicle::Truck"
    end

    integer :cost
  end

  def subscriber_id
    self.manufacturer.subscriber_id
  end

  belongs_to :manufacturer
  def cached_manufacturer
    ::Manufacturer.cached_find_by(:id => self.manufacturer_id)
  end

  class Car < ::Vehicle
  end

  class Truck < ::Vehicle
  end
end

class Widget < ::ActiveRecord::Base
  include ::Trax::Model

  mixins :unique_id => { :uuid_column => "uuid", :uuid_prefix => "2a" },
         :cached_relations => true

  validates :subdomain, :subdomain => true, :allow_nil => true
  validates :email_address, :email => true, :allow_nil => true
  validates :website, :url => true, :allow_nil => true

  belongs_to :subscriber
  cached_belongs_to :subscriber
end

class Message < ::ActiveRecord::Base
  include ::Trax::Model

  mixins :unique_id => { :uuid_column => "uuid", :uuid_prefix => "3a" },
         :freezable => true,
         :restorable => { :field => :deleted, :hide_deleted => true },
         :field_scopes => {
           :by_title => true,
           :by_title_case_insensitive => { :field => :title, :type => :where_lower}
         }

  enum :status => [ :queued, :scheduled, :delivered, :failed_delivery ]

  default_value_for :status do
    self.statuses[:queued]
  end

  validates :deliver_at, :future => true, :allow_nil => true

  freezable_by_enum :status => [ :delivered, :failed_delivery ]
end

class Thing < ::ActiveRecord::Base
  include ::Trax::Model

  mixins :unique_id => { :uuid_column => "uuid", :uuid_prefix => "4a" }
end

class Person < ::ActiveRecord::Base
  include ::Trax::Model

  mixins :unique_id => { :uuid_column => "uuid", :uuid_prefix => "5a" },
         :cached_find_by => true

  belongs_to :vehicle
  def cached_vehicle
    ::Vehicle.cached_find_by(:id => self.vehicle_id)
  end
end

class StoreCategory < ::Trax::Core::Types::Struct
  include ::Trax::Model::ExtensionsFor::Struct

  string :name
  struct :meta_attributes do
    string :description
    string :keywords
  end
end

class User < ::ActiveRecord::Base
  include ::Trax::Model
  include ::Trax::Model::Attributes::Dsl

  mixins :unique_id => { :uuid_column => "uuid", :uuid_prefix => "3e" },
         :cached_find_by => true,
         :cached_relations => true

  define_attributes do
    enum :role, :default => :staff do
      define :staff, 1
      define :admin, 2
      define :billing, 3
    end
  end
end

class Animal < ::ActiveRecord::Base
  include ::Trax::Model
  include ::Trax::Model::Attributes::Dsl
end

class Mammal < ::Animal
  include ::Trax::Model
  include ::Trax::Model::Attributes::Dsl

  define_attributes do
    struct :characteristics, :model_accessors => true do
      string :fun_facts
    end
  end
end
