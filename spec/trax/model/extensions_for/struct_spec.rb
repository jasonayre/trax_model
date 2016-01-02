require 'spec_helper'

describe ::Trax::Model::ExtensionsFor::Struct, :postgres => true do
  subject{ ::Ecommerce::Products::MensShoes }

  let(:product_one_last_received_at) { ::Time.now - 10.days }
  let(:product_two_last_received_at) { ::Time.now - 5.days }
  let(:product_one_size) { :mens_6 }
  let(:product_two_size) { :mens_7 }

  let!(:product_one) {
    ::Ecommerce::Products::MensShoes.create(
      "name" => "DC Villan Size 6",
      "custom_fields" => {
        "size" => product_one_size,
        "slug" => "dc-villan-size-6",
        "has_shoelaces" => true,
        "display_name" => "DC Villan Mens Shoes Size 6",
        "last_received_at" => product_one_last_received_at,
        "cost" => 15,
        "price" => 29.99
      }
    )
  }

  let!(:product_two) {
    ::Ecommerce::Products::MensShoes.create(
      "name" => "DC Villan Size 7",
      "custom_fields" => {
        "size" => product_two_size,
        "slug" => "dc-villan-size-7",
        "has_shoelaces" => false,
        "display_name" => "DC Villan Mens Shoes Size 7",
        "last_received_at" => product_two_last_received_at,
        "cost" => 20,
        "price" => 39.99
      }
    )
  }

  context "boolean" do
    context "eq" do
      it {
        expect(subject.fields[:custom_fields][:has_shoelaces].eq(true, false)).to include(product_one, product_two)
      }
    end

    context "is_true" do
      it {
        expect(subject.fields[:custom_fields][:has_shoelaces].is_true).to include(product_one)
      }
      it {
        expect(subject.fields[:custom_fields][:has_shoelaces].is_true).to_not include(product_two)
      }
    end

    context "is_false" do
      it {
        expect(subject.fields[:custom_fields][:has_shoelaces].is_false).to include(product_two)
      }
      it {
        expect(subject.fields[:custom_fields][:has_shoelaces].is_false).to_not include(product_one)
      }
    end

    context "is_nil" do
      it {
        expect(subject.fields[:custom_fields][:has_shoelaces].is_nil).to_not include(product_one, product_two)
      }
    end
  end

  context "enum" do
    context "eq" do
      it {
        expect(subject.fields[:custom_fields][:size].eq(product_two_size)).to include(product_two)
      }
      it {
        expect(subject.fields[:custom_fields][:size].eq(product_two_size)).to_not include(product_one)
      }
      it {
        expect(subject.fields[:custom_fields][:size].eq(product_two_size, product_one_size)).to include(product_one, product_two)
      }
      it {
        expect(subject.fields[:custom_fields][:size].eq(1,2)).to include(product_one, product_two)
      }
    end
  end

  context "string" do
    context "eq" do
      it {
        expect(subject.fields[:custom_fields].fields[:slug].eq("dc-villan-size-6")).to include(product_one)
      }
      it {
        expect(subject.fields[:custom_fields].fields[:slug].eq("dc-villan-size-6")).to_not include(product_two)
      }
      it {
        expect(subject.fields[:custom_fields].fields[:slug].eq("dc-villan-size-6", "dc-villan-size-7")).to include(product_two, product_one)
      }
    end

    context "eq_lower" do
      it {
        expect(subject.fields[:custom_fields].fields[:display_name].eq_lower("dc villan mens shoes size 6")).to include(product_one)
      }
      it {
        expect(subject.fields[:custom_fields].fields[:display_name].eq_lower("DC Villan Mens Shoes Size 6", "DC Villan Mens Shoes Size 7")).to include(product_one, product_two)
      }
      it {
        expect(subject.fields[:custom_fields].fields[:display_name].eq_lower("DC Villan Mens Shoes Size 7")).to_not include(product_one)
      }
    end

    context "matches" do
      it {
        expect(subject.fields[:custom_fields].fields[:slug].matches("dc-villan-size")).to include(product_one, product_two)
      }
      it {
        expect(subject.fields[:custom_fields].fields[:slug].matches("blah")).to_not include(product_one, product_two)
      }
    end
  end

  context "time" do
    context "after" do
      it {
        expect(subject.fields[:custom_fields].fields[:last_received_at].after(::Time.now - 6.days)).to include(product_two)
      }
      it {
        expect(subject.fields[:custom_fields].fields[:last_received_at].after(::Time.now - 6.days)).to_not include(product_one)
      }
    end

    context "before" do
      it {
        expect(subject.fields[:custom_fields].fields[:last_received_at].before(::Time.now - 6.days)).to include(product_one)
      }
      it {
        expect(subject.fields[:custom_fields].fields[:last_received_at].before(::Time.now - 6.days)).to_not include(product_two)
      }
    end

    context "between" do
      let(:start_time) { ::Time.now - 6.days}
      let(:end_time) { ::Time.now - 4.days }
      it {
        expect(subject.fields[:custom_fields].fields[:last_received_at].between(start_time, end_time)).to include(product_two)
      }
      it {
        expect(subject.fields[:custom_fields].fields[:last_received_at].between(start_time, end_time)).to_not include(product_one)
      }
    end
  end

  context "float" do
    context "eq" do
      it {
        expect(subject.fields[:custom_fields].fields[:price].eq(29.99)).to include(product_one)
      }
      it {
        expect(subject.fields[:custom_fields].fields[:price].eq(29.99)).to_not include(product_two)
      }
      it {
        expect(subject.fields[:custom_fields].fields[:price].eq(29.99, 39.99)).to include(product_two)
      }
    end

    context "gt" do
      it {
        expect(subject.fields[:custom_fields].fields[:price].gt(29.99)).to include(product_two)
      }
      it {
        expect(subject.fields[:custom_fields].fields[:price].gt(29.99)).to_not include(product_one)
      }
      it {
        expect(subject.fields[:custom_fields].fields[:price].gt(29.99)).to_not include(product_one)
      }
    end

    context "gte" do
      it {
        expect(subject.fields[:custom_fields].fields[:price].gte(39.99)).to include(product_two)
      }
      it {
        expect(subject.fields[:custom_fields].fields[:price].gte(39.99)).to_not include(product_one)
      }
    end

    context "lt" do
      it {
        expect(subject.fields[:custom_fields].fields[:price].lt(39.99)).to include(product_one)
      }
      it {
        expect(subject.fields[:custom_fields].fields[:price].gt(39.99)).to_not include(product_two)
      }
    end

    context "lte" do
      it {
        expect(subject.fields[:custom_fields].fields[:price].lte(29.99)).to include(product_one)
      }
      it {
        expect(subject.fields[:custom_fields].fields[:price].lte(29.99)).to_not include(product_two)
      }
    end

    context "between" do
      it {
        expect(subject.fields[:custom_fields].fields[:price].between(28.99, 30.00)).to include(product_one)
      }
      it {
        expect(subject.fields[:custom_fields].fields[:price].between(29.99, 30.00)).to_not include(product_one)
      }
    end

    context "in_range" do
      it {
        expect(subject.fields[:custom_fields].fields[:price].in_range(29.99, 30.00)).to include(product_one)
      }
    end
  end
end
