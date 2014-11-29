require 'spec_helper'

describe ::Trax::Model::UUID do
  let(:product) { ::Product.create(:name => "iMac") }
  subject{ product.uuid }

  its(:record_type) { should eq ::Product }
  its(:record) { should eq product }
  
  describe ".generate" do
    context "with prefix" do
      let(:prefixed_uuid) { described_class.generate("1a") }
      it { prefixed_uuid[0..1].should eq "1a" }
    end

    context "without prefix" do
      let(:unprefixed_uuid) { described_class.generate }
      it { unprefixed_uuid.length.should eq 36 }
    end
  end
end
