require 'spec_helper'

describe ::Trax::Model::ExtensionsFor::String do
  subject{ ::Product }

  let!(:product_one) {
    ::Product.create(:name => "DC Villan Size 6")
  }
  let!(:product_two) {
    ::Product.create(:name => "DC Villan Size 7")
  }

  context ".eq" do
    it { expect(subject.fields[:name].eq("DC Villan Size 6")).to include(product_one) }
  end

end
