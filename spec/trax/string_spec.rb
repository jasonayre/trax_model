require 'spec_helper'
describe ::String do
  let(:product) { ::Product.create(:name => "iMac") }
  subject{ "#{product.uuid}" }

  it{ expect(subject.uuid).to be_instance_of(::Trax::Model::UUID) }

  its(:uuid) { should be_instance_of(::Trax::Model::UUID) }

  context "when not a uuid length" do
    let(:truncated_uuid) { subject[0..8] }
    it { expect(truncated_uuid.uuid).to be_nil }
  end
end
