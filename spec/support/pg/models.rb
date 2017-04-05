

module Ecommerce
  class PageView < ::Trax::Core::Types::Struct
    enum :site do
      define :website_1
      define :website_2
    end

    string :url
  end

  class SessionHistorySet < ::Trax::Core::Types::Set
    contains_instances_of ::Ecommerce::PageView
  end

  class SharedDefinitions < ::Trax::Core::Blueprint
    struct :location do
      string :street_address
      string :ip_address

      enum :country do
        define :united_states, 1
        define :canada, 2
      end
    end
  end

  class ProductAttributeSet < ::ActiveRecord::Base
    self.table_name = "ecommerce_product_attribute_sets"

    include ::Trax::Model
    include ::Trax::Model::Attributes::Dsl

    mixins :unique_id => { :uuid_prefix => "c2" }
  end

  class ShippingAttributes < ::Ecommerce::ProductAttributeSet
    include ::Trax::Model
    include ::Trax::Model::Attributes::Dsl

    define_attributes do
      struct :specifics, :model_accessors => true, :validate => true do
        include ::ActiveModel::Validations

        integer :cost, :default => 0
        validates(:cost, :numericality => {:greater_than => 0})
        integer :tax
        string :delivery_time

        enum :service do
          define :usps,  1
          define :fedex, 2
        end

        struct :dimensions do
          include ::ActiveModel::Validations

          integer :length
          integer :width
          integer :height
          string :packaging_box

          validates(:length, :numericality => {:greater_than => 0})
        end

        define_model_scope_for :cost, :as => :by_cost
      end
    end
  end

  class User < ::ActiveRecord::Base
    self.table_name = "ecommerce_users"
    attr_accessor :speaks_spanish

    include ::Trax::Model
    include ::Trax::Model::Attributes::Dsl

    mixins :unique_id => { :uuid_prefix => "9b" }

    def speaks_spanish
      @speaks_spanish ||= false
    end

    define_attributes do
      struct :locales, :default => lambda{ |record|
        { :en => false, :es => record.speaks_spanish }
      } do
        boolean :en, :default => false
        boolean :es, :default => false
      end

      set :sign_in_locations, :contains_instances_of => ::Ecommerce::SharedDefinitions::Fields::Location
      set :shopping_cart_sessions, :contains_instances_of => ::Ecommerce::SessionHistorySet
    end
  end

  class Vote < ::ActiveRecord::Base
    self.table_name = "ecommerce_votes"

    include ::Trax::Model
    include ::Trax::Model::Attributes::Dsl

    mixins :unique_id => { :uuid_prefix => "9d" }

    define_attributes do
      set :upvoter_ids
      set :downvoter_ids
      array :upvoter_ids_array
      array :downvoter_ids_array
    end
  end

  class Product < ::ActiveRecord::Base
    self.table_name = "ecommerce_products"

    include ::Trax::Model
    include ::Trax::Model::Attributes::Dsl

    mixins :unique_id => { :uuid_prefix => "9a" }

    belongs_to :store, :class_name => "Ecommerce::Store"

    define_attributes do
      string :name, :default => "Whatever" do
        validates(self, :length => { :minimum => 20 })
      end
      boolean :active, :default => true

      uuid_array :related_product_ids

      enum :status, :default => :in_stock do
        define :in_stock,     1
        define :out_of_stock, 2
        define :backordered,  3
      end

      struct :custom_fields do
        integer :cost
        integer :in_stock_quantity, :default => 0
        integer :number_of_sales, :default => 0
        float :price
        time :last_received_at
        string :slug
        string :display_name

        define_model_scope_for :in_stock_quantity, :as => :by_quantity_in_stock
        define_model_scope_for :last_received_at, :as => :by_last_received_at
      end
    end
  end

  module Products
    class Shoes < ::Ecommerce::Product
      include ::Trax::Model
      include ::Trax::Model::Attributes::Dsl

      define_attributes do
      end
    end

    class MensShoes < ::Ecommerce::Products::Shoes
      include ::Trax::Model
      include ::Trax::Model::Attributes::Dsl

      define_attributes do
        string :name, :default => "Some Shoe Name"
        boolean :active, :default => true

        struct :custom_fields, :extends => ::Ecommerce::Product::Fields::CustomFields do
          string :primary_utility, :default => "Skateboarding"
          string :sole_material
          boolean :has_shoelaces

          array :tags

          enum :color, :default => :blue do
            define :red,   1
            define :blue,  2
            define :green, 3
            define :black, 4
          end

          enum :size, :default => :mens_9 do
            define :mens_6,  1
            define :mens_7,  2
            define :mens_8,  3
            define :mens_9,  4
            define :mens_10, 5
            define :mens_11, 6
            define :mens_12, 7
          end

          def total_profit
            number_of_sales * (price - cost)
          end

          define_model_scopes_for(:primary_utility, :has_shoelaces, :size)
          define_model_scope_for :tags, :as => :by_tags
        end
      end
    end
  end
end
