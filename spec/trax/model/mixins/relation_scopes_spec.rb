require 'spec_helper'

describe ::Trax::Model::Mixins::RelationScopes do
  let!(:skate_shoes_category) { ::Category.create(:name => "skate_shoes") }
  let!(:running_shoes_category) { ::Category.create(:name => "running_shoes") }
  let!(:ray_shoes_category) { ::Category.create(:name => "RAY_shoes") }
  let!(:skate_shoes_product_one) { ::Product.create(:name => "Command", :category => skate_shoes_category, :in_stock_quantity => 5, :on_order_quantity => 3) }
  let!(:skate_shoes_product_two) { ::Product.create(:name => "Villan", :category => skate_shoes_category, :in_stock_quantity => 3, :on_order_quantity => 2) }
  let!(:running_shoes_product_one) { ::Product.create(:name => "some_running_shoes", :category => running_shoes_category, :in_stock_quantity => 2, :on_order_quantity => 0) }
  let!(:ray_shoes_product_one) { ::Product.create(:name => "some_ray_shoes", :category => ray_shoes_category, :in_stock_quantity => 1, :on_order_quantity => 0) }

  subject { ::Product }

  ##todo:

  context "type 'matches'" do
    it { expect(subject.by_category_name_matches("skate")).to be_present }
    # it { expect(subject.by_title(known_title.downcase)).to be_empty }
    # it { expect(subject.by_title(known_title.upcase)).to be_empty }
    #
    # it { expect(subject.by_title(*known_titles)).to be_present }
    # it { expect(subject.by_title(*known_titles.map(&:downcase))).to be_empty }
    # it { expect(subject.by_title(*known_titles.map(&:upcase))).to be_empty }
    #
    # it { expect(subject.by_title(known_titles_relation)).to be_present }
    # it { expect(subject.by_title(known_titles_downcased_relation)).to be_empty }
    # it { expect(subject.by_title(known_titles_upcased_relation)).to be_empty }
    #
    # it { expect(subject.by_title(unknown_title)).to be_empty }
  end

  context "type 'where_lower'" do
    # it { expect(subject.by_title_case_insensitive(known_title)).to be_present }
    # it { expect(subject.by_title_case_insensitive(known_title.downcase)).to be_present }
    # it { expect(subject.by_title_case_insensitive(known_title.upcase)).to be_present }
    #
    # it { expect(subject.by_title_case_insensitive(*known_titles)).to be_present }
    # it { expect(subject.by_title_case_insensitive(*known_titles.map(&:downcase))).to be_present }
    # it { expect(subject.by_title_case_insensitive(*known_titles.map(&:upcase))).to be_present }
    #
    # it { expect(subject.by_title_case_insensitive(known_titles_relation)).to be_empty }
    # it { expect(subject.by_title_case_insensitive(known_titles_downcased_relation)).to be_present }
    # it { expect(subject.by_title_case_insensitive(known_titles_upcased_relation)).to be_empty }
    #
    # it { expect(subject.by_title_case_insensitive(unknown_title)).to be_empty }
  end
end
