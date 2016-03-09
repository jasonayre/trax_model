require 'spec_helper'

describe ::Trax::Model::Attributes::Types::UuidArray, :postgres => true do
  let(:related_product) { ::Ecommerce::Product.create(:name => "ipod") }
  subject{ ::Ecommerce::Product.new(:name => "ipad", :related_product_ids => [related_product.id]) }

  it { expect(subject.related_product_ids).to be_a(::Trax::Model::UUIDArray) }
  it { expect(subject.related_product_ids).to include(related_product.id) }

  context "attribute definition" do
    subject { ::Ecommerce::Product::Fields::RelatedProductIds.new }
    it { expect(subject).to be_a(::Trax::Model::UUIDArray) }
  end

  context "dirty tracking" do
    let(:product_three) { ::Ecommerce::Product.create(:name => "thirdprod") }
    it {
      subject.save
      subject.related_product_ids = [product_three.id]
      expect(subject.related_product_ids_was).to eq [related_product.id]
    }
  end

  #note: only supports string values for scopes at the moment
  #also note: I think this is the ideal api for the future.
  #I.e. define a scope on the model, by referencing the field directly.
  context "relations" do
    let!(:record_one) {
      ::Ecommerce::Product.create(:related_product_ids => [], :name => 'prodone')
    }
    let!(:record_two) {
      ::Ecommerce::Product.create(:related_product_ids => [record_one.id], :name => 'prodtwo')
    }
    it {
      expect(
        ::Ecommerce::Product::Fields::RelatedProductIds.contains(record_one.id)
      ).to include record_two
    }
    it {
      expect(
        ::Ecommerce::Product::Fields::RelatedProductIds.contains(record_two.id)
      ).to_not include record_one
    }
  end
end
