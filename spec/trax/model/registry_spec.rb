require 'spec_helper'

describe ::Trax::Model::Registry do
  subject{ described_class }

  its(:models) { should be_instance_of(::Hashie::Mash) }
  its(:uuid_map) { should have_key("1a") }
  its(:uuid_map) { should be_instance_of(::Hashie::Mash) }

  it "should have registered product model" do
    subject.key?(:product).should be true
  end

  it "model_type_for_uuid" do
    subject.model_type_for_uuid("1absdasdasd").should eq Product
  end
end
