require 'spec_helper'

describe ::Trax::Model::ExtensionsFor::Boolean do
  subject{ ::Product }

  let!(:product_one) {
    ::Product.create(:name => "DC Villan Size 6", :active => true)
  }
  let!(:product_two) {
    ::Product.create(:name => "DC Villan Size 7", :active => false)
  }

  context ".eq" do
    it { expect(subject.fields[:active].eq(true, false)).to include(product_one, product_two) }
  end
end
