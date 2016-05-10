require 'spec_helper'

describe ::Trax::Model::Mixins::SortScopes do
  let!(:skate_shoes_category) { ::Category.create(:name => "skate_shoes") }
  let!(:running_shoes_category) { ::Category.create(:name => "running_shoes") }
  let!(:ray_shoes_category) { ::Category.create(:name => "RAY_shoes") }
  let!(:skate_shoes_product_one) { ::Product.create(:name => "Command", :category => skate_shoes_category, :in_stock_quantity => 5, :on_order_quantity => 3) }
  let!(:skate_shoes_product_two) { ::Product.create(:name => "Villan", :category => skate_shoes_category, :in_stock_quantity => 3, :on_order_quantity => 2) }
  let!(:running_shoes_product_one) { ::Product.create(:name => "some_running_shoes", :category => running_shoes_category, :in_stock_quantity => 2, :on_order_quantity => 0) }
  let!(:ray_shoes_product_one) { ::Product.create(:name => "some_ray_shoes", :category => ray_shoes_category, :in_stock_quantity => 1, :on_order_quantity => 0) }

  subject { ::Category.all }

  context "string values are sorted using lower" do
    it do
      expect(subject.sort_by_name_asc.first.name).to eq "RAY_shoes"
    end
  end

  context "related sort scope" do
    it do
      expect(subject.sort_by_most_in_stock_asc.first.name).to eq "RAY_shoes"
      expect(subject.sort_by_most_in_stock_desc.first.name).to eq "skate_shoes"
    end

    it do
      expect(subject.sort_by_least_oversold_asc.first.name).to eq "running_shoes"
      expect(subject.sort_by_least_oversold_desc.first.name).to eq "skate_shoes"
    end
  end
end
