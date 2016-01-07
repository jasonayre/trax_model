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
#
# class Blueprint < ::Trax::Core::Blueprint
#   class Vehicle < ::Trax::Core::Blueprint
#     enum :kind do
#       define :car, 1, :type => "Vehicle::Car"
#       define :truck, 2, :type => "Vehicle::Truck"
#     end
#   end
# end

class Product < ::ActiveRecord::Base
  include ::Trax::Model
  include ::Trax::Model::Attributes::Dsl

  mixins :unique_id => {
    :uuid_column => "uuid",
    :uuid_prefix => "1a"
  }

  define_attributes do
    string :name
    # float :price

    integer :in_stock_quantity
    integer :out_of_stock_quantity

    enum :status, :default => :in_stock do
      define :in_stock,     1
      define :out_of_stock, 2
      define :backordered,  3
    end

    boolean :active, :default => false
  end
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
    end
  end
end

class Subscriber < ::ActiveRecord::Base
  include ::Trax::Model
  include ::Trax::Model::Attributes::Dsl

  mixins :unique_id => { :uuid_column => "uuid", :uuid_prefix => "4f" },
         :cached_methods => true,
         :cached_relations => true

  has_many :manufacturers
  # cached_has_many :manufacturers
end

class Manufacturer < ::ActiveRecord::Base
  include ::Trax::Model
  include ::Trax::Model::Attributes::Dsl

  mixins :unique_id => { :uuid_column => "uuid", :uuid_prefix => "3d" },
         :cached_methods => true,
         :cached_relations => true

  has_many :vehicles
  cached_method :vehicles

  belongs_to :subscriber
  cached_belongs_to :subscriber

  def self.total_cost_of_vehicles_for_all_manufacturers
    _costs = all.map { |record| record.vehicles.pluck(:cost) }.flatten.compact.reduce(:+)
  end
  cached_class_method :total_cost_of_vehicles_for_all_manufacturers
end

class Vehicle < ::ActiveRecord::Base
  include ::Trax::Model
  include ::Trax::Model::Attributes::Dsl

  mixins :unique_id => { :uuid_column => "uuid", :uuid_prefix => "9c" },
         :sti_enum  => true,
         :cached_methods => true,
         :cached_relations => true

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
  cached_belongs_to :manufacturer, :scope => :subscriber_id

  class Car < ::Vehicle
  end

  class Truck < ::Vehicle
  end
end

class Widget < ::ActiveRecord::Base
  include ::Trax::Model

  mixins :unique_id => {
    :uuid_column => "uuid",
    :uuid_prefix => "2a"
  }

  validates :subdomain, :subdomain => true, :allow_nil => true
  validates :email_address, :email => true, :allow_nil => true
  validates :website, :url => true, :allow_nil => true
end

class Message < ::ActiveRecord::Base
  include ::Trax::Model

  mixins :unique_id => { :uuid_column => "uuid", :uuid_prefix => "3a" },
         :freezable => true,
         :restorable => { :field => :deleted },
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
         :cached_relations => true

  belongs_to :vehicle
  cached_belongs_to :vehicle
end

class StoreCategory < ::Trax::Core::Types::Struct
  include ::Trax::Model::ExtensionsFor::Struct

  string :name
  struct :meta_attributes do
    string :description
    string :keywords
  end
end
