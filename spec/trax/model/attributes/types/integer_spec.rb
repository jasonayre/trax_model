require 'spec_helper'

describe ::Trax::Model::Attributes::Types::Integer do
  subject{ ::Products::MensShoes::Fields::Quantity }

  context "model" do
    subject {
      ::Products::MensShoes.new(:in_stock_quantity => 1)
    }

    it { expect(subject.in_stock_quantity).to eq 1 }

    context "non integer value" do
      let(:test_subject) { ::Products::MensShoes.new(:in_stock_quantity => "blah") }
      it { expect(test_subject.in_stock_quantity).to eq 0 }
    end
  end

  context "struct attribute", :postgres => true do
    subject {
      ::Ecommerce::Products::MensShoes.new(:in_stock_quantity => 1)
    }
  end
end
