require 'spec_helper'

describe ::Trax::Model::Mixins::CachedMethods do
  context "cached class methods" do
    subject {
      ::Product
    }

    let(:keys_in_cache) { ::Trax::Model.cache.instance_variable_get(:@data).keys }

    it {
      expect(subject.cached_inventory_cost).to eq 0
      expect(keys_in_cache).to include("product.inventory_cost")
      subject.inventory_cost = 20
      expect(subject.cached_inventory_cost).to eq 0

      Timecop.freeze(Time.now + 30.minutes) do
        expect(subject.cached_inventory_cost).to eq 20
      end
    }

    context "method that accepts args" do
      let!(:product_1) { Product.create(:in_stock_quantity => 5) }
      let!(:product_2) { Product.create(:in_stock_quantity => 5) }
      let!(:product_3) { Product.create(:in_stock_quantity => 1) }

      it {
        expect(subject.cached_in_stock_quantities([product_1.id])).to eq 5
        expect(subject.cached_in_stock_quantities([product_1.id, product_2.id])).to eq 10
        expect(subject.cached_in_stock_quantities([product_3.id])).to eq 1
        expect(subject.cached_in_stock_quantities([product_1.id, product_3.id])).to eq 6
        expect(keys_in_cache).to include("product.in_stock_quantities/[1]")
        expect(keys_in_cache).to include("product.in_stock_quantities/[1, 2]")
        expect(keys_in_cache).to include("product.in_stock_quantities/[1, 3]")

        product_3.update_attributes(:in_stock_quantity => 20)
        product_3.reload
        expect(subject.cached_in_stock_quantities([product_3.id])).to eq 1

        Timecop.freeze(Time.now + 30.minutes) do
          expect(subject.cached_in_stock_quantities([product_3.id])).to eq 20
        end
      }
    end
  end
end
