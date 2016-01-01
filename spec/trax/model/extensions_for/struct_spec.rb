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
        "last_received_at" => product_two_last_received_at,
        "cost" => 20,
        "price" => 39.99
      }
    )
  }

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
    context "gt" do
      it {
        expect(subject.fields[:custom_fields].fields[:price].gt(30.00)).to include(product_two)
      }

      it {
        expect(subject.fields[:custom_fields].fields[:price].gt(30.00)).to_not include(product_one)
      }

    end
  end
end
