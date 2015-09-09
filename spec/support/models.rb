require 'active_record'

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
  include ::Trax::Model::Attributes::Mixin

  mixins :unique_id => {
    :uuid_column => "uuid",
    :uuid_prefix => "1a"
  }

  define_attributes do
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
    include ::Trax::Model::Attributes::Mixin
  end

  class MensShoes < Shoes
    include ::Trax::Model
    include ::Trax::Model::Attributes::Mixin

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
         :restorable => { :field => :deleted }

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

  mixins :unique_id => { :uuid_column => "uuid", :uuid_prefix => "5a" }
end

class Stapler < ::ActiveRecord::Base
  include ::Trax::Model
end

class SwinglineStapler < ::Stapler
  include ::Trax::Model::STI::Attributes
end

class SwinglineStaplerAttributeSet < ::ActiveRecord::Base
end

require 'trax/model/struct'

class StoreCategory < ::Trax::Model::Struct
  string :name
  struct :meta_attributes do
    string :description
    string :keywords
  end
end
