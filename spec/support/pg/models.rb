module Ecommerce
  class ProductAttributeSet < ::ActiveRecord::Base
    self.table_name = "ecommerce_product_attribute_sets"

    include ::Trax::Model
    include ::Trax::Model::Attributes::Mixin

    mixins :unique_id => { :uuid_prefix => "c2" }

    # belongs_to :user, :class_name => "Ecommerce::User"
    # belongs_to :product, :class_name => "Ecommerce::Product"
  end

  class ShippingAttributes < ::Ecommerce::ProductAttributeSet
    include ::Trax::Model
    include ::Trax::Model::Attributes::Mixin

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
      end
    end
  end

  class Product < ::ActiveRecord::Base
    self.table_name = "ecommerce_products"

    include ::Trax::Model
    include ::Trax::Model::Attributes::Mixin

    mixins :unique_id => { :uuid_prefix => "9a" }

    belongs_to :store, :class_name => "Ecommerce::Store"

    define_attributes do
      string :name, :default => "Whatever" do
        validates(self, :length => { :minimum => 20 })
      end
      boolean :active, :default => true

      enum :status, :default => :in_stock do
        define :in_stock,     1
        define :out_of_stock, 2
        define :backordered,  3
      end
    end
  end

  module Products
    class Shoes < ::Ecommerce::Product
      include ::Trax::Model
      include ::Trax::Model::Attributes::Mixin
    end

    class MensShoes < ::Ecommerce::Products::Shoes
      include ::Trax::Model
      include ::Trax::Model::Attributes::Mixin

      define_attributes do
        string :name, :default => "Some Shoe Name"
        boolean :active, :default => true

        struct :custom_fields do
          string :primary_utility, :default => "Skateboarding"
          string :sole_material
          boolean :has_shoelaces
          integer :in_stock_quantity, :default => 0
          integer :number_of_sales, :default => 0
          integer :cost
          integer :price

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
        end
      end
    end
  end
end
