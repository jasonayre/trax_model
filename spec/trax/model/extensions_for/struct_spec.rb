require 'spec_helper'
describe ::Trax::Model::ExtensionsFor::Struct do
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
        "last_received_at" => product_one_last_received_at
      }
    )
  }

  let!(:product_two) {
    ::Ecommerce::Products::MensShoes.create(
      "name" => "DC Villan Size 7",
      "custom_fields" => {
        "size" => product_two_size,
        "last_received_at" => product_two_last_received_at
      }
    )
  }

  context "time" do
    it {
      expect(subject.fields[:custom_fields].fields[:last_received_at].after(::Time.now - 6.days)).to include(product_two)
    }
  end
end
