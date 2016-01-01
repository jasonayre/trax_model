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
    it { expect(subject.fields[:name].eq("DC Villan Size 7")).to_not include(product_one) }
  end

  context ".eq_lower" do
    it { expect(subject.fields[:name].eq_lower("dc Villan Size 6")).to include(product_one) }
  end

  context ".matches", :postgres => true do
    it { expect(subject.fields[:name].matches("dc")).to include(product_one, product_two) }
  end
end
