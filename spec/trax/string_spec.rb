require 'spec_helper'
describe ::String do
  let(:product) { ::Product.create(:name => "iMac") }
  subject{ "#{product.uuid}" }

  its(:uuid) {
    should be_instance_of(::Trax::Model::UUID)
  }

  context "when not a uuid length" do
    let(:truncated_uuid) { subject[0..8] }
    it { truncated_uuid.uuid.should be_nil }
  end
end
