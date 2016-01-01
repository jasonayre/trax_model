require 'spec_helper'

describe ::Trax::Model::ExtensionsFor::Numeric do
  subject{ ::Product }

  let!(:product_one) {
    ::Product.create(:name => "DC Villan Size 6", :in_stock_quantity => 5)
  }
  let!(:product_two) {
    ::Product.create(:name => "DC Villan Size 7", :in_stock_quantity => 9)
  }

  context "Integer" do
    context ".between" do
      it { expect(subject.fields[:in_stock_quantity].between(5, 10)).to include(product_two) }
      it { expect(subject.fields[:in_stock_quantity].between(5, 10)).to_not include(product_one) }
      # it { expect(subject.fields[:in_stock_quantity].eq(5)).to_not include(product_two) }
      # it { expect(subject.fields[:in_stock_quantity].eq(5,9)).to include(product_two, product_one) }
    end

    context ".eq" do
      it { expect(subject.fields[:in_stock_quantity].eq(5)).to include(product_one) }
      it { expect(subject.fields[:in_stock_quantity].eq(5)).to_not include(product_two) }
      it { expect(subject.fields[:in_stock_quantity].eq(5,9)).to include(product_two, product_one) }
    end

    context ".gt" do
      it { expect(subject.fields[:in_stock_quantity].gt(5)).to include(product_two) }
      it { expect(subject.fields[:in_stock_quantity].gt(5)).to_not include(product_one) }
    end

    context ".lt" do
      it { expect(subject.fields[:in_stock_quantity].lt(9)).to include(product_one) }
      it { expect(subject.fields[:in_stock_quantity].lt(5)).to_not include(product_two) }
    end
  end

  # context "Integer" do
  #   context ".eq" do
  #     it { expect(subject.fields[:in_stock_quantity].eq(5)).to include(product_one) }
  #     it { expect(subject.fields[:in_stock_quantity].eq(5)).to_not include(product_two) }
  #     it { expect(subject.fields[:in_stock_quantity].eq(5,9)).to include(product_two, product_one) }
  #   end
  #
  #   context ".gt" do
  #     it { expect(subject.fields[:in_stock_quantity].gt(5)).to include(product_two) }
  #     it { expect(subject.fields[:in_stock_quantity].gt(5)).to_not include(product_one) }
  #   end
  #
  #   context ".lt" do
  #     it { expect(subject.fields[:in_stock_quantity].lt(9)).to include(product_one) }
  #     it { expect(subject.fields[:in_stock_quantity].lt(5)).to_not include(product_two) }
  #   end
  # end
end
