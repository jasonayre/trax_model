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

      it {
        expect(subject.cached_in_stock_quantities([product_1.id])).to eq 5
        expect(subject.cached_in_stock_quantities([product_1.id, product_2.id])).to eq 10
        expect(keys_in_cache).to include("product.in_stock_quantities/[#{product_1.id}]")
        expect(keys_in_cache).to include("product.in_stock_quantities/[#{product_1.id}, #{product_2.id}]")

        product_1.update_attributes(:in_stock_quantity => 20)
        product_1.reload
        expect(subject.cached_in_stock_quantities([product_1.id])).to eq 5

        Timecop.freeze(Time.now + 30.minutes) do
          expect(subject.cached_in_stock_quantities([product_1.id])).to eq 20
        end
      }
    end

    context "method that accepts args which splats" do
      let!(:product_1) { Product.create(:in_stock_quantity => 5) }
      let!(:product_2) { Product.create(:in_stock_quantity => 5) }

      it {
        expect(subject.cached_in_stock_quantities_splat(product_1.id)).to eq 5
        expect(subject.cached_in_stock_quantities_splat(product_1.id, product_2.id)).to eq 10
        expect(keys_in_cache).to include("product.in_stock_quantities_splat/#{product_1.id}")
        expect(keys_in_cache).to include("product.in_stock_quantities_splat/#{product_1.id}/#{product_2.id}")

        product_1.update_attributes(:in_stock_quantity => 20)
        product_1.reload
        expect(subject.cached_in_stock_quantities_splat(product_1.id)).to eq 5

        Timecop.freeze(Time.now + 30.minutes) do
          expect(subject.cached_in_stock_quantities_splat(product_1.id)).to eq 20
        end
      }
    end

    context "method that accepts keyword args" do
      let!(:product_1) { Product.create(:in_stock_quantity => 5) }
      let!(:product_2) { Product.create(:in_stock_quantity => 5) }

      it {
        expect(subject.cached_in_stock_quantities_keywords(:ids => [product_1.id])).to eq 5
        expect(subject.cached_in_stock_quantities_keywords(:ids => [product_1.id, product_2.id])).to eq 10
        expect(keys_in_cache).to include("product.in_stock_quantities_keywords/ids/#{product_1.id}")
        expect(keys_in_cache).to include("product.in_stock_quantities_keywords/ids/#{product_1.id}/#{product_2.id}")

        product_1.update_attributes(:in_stock_quantity => 20)
        product_1.reload
        expect(subject.cached_in_stock_quantities_keywords(:ids => [product_1.id])).to eq 5

        Timecop.freeze(Time.now + 30.minutes) do
          expect(subject.cached_in_stock_quantities_keywords(:ids => [product_1.id])).to eq 20
        end
      }
    end
  end

  context "cached instance methods" do
    before { ::Product.inventory_cost = 0 }
    subject {
      ::Product.create(:name => "whatever")
    }

    let(:keys_in_cache) { ::Trax::Model.cache.instance_variable_get(:@data).keys }

    it {
      expect(subject.cached_some_cached_instance_method).to eq 0
      expect(keys_in_cache).to include("product#some_cached_instance_method/#{subject.id}")
      subject.class.inventory_cost = 20
      expect(subject.cached_some_cached_instance_method).to eq 0

      Timecop.freeze(Time.now + 30.minutes) do
        expect(subject.cached_some_cached_instance_method).to eq 20
      end
    }
  end
end
