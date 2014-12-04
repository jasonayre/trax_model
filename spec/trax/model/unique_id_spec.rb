require 'spec_helper'
describe ::Trax::Model::UniqueId do
  subject{ ::Product }

  its(:uuid_prefix) {
    should be_instance_of(::Trax::Model::UUIDPrefix)
  }

  describe "uuid_prefix" do
    context "bad prefixes" do
      ["a", "1p", "a1a", "bl", "1", "111"].each do |prefix|
        it "raises error when passed hex incompatible prefix #{prefix}" do
          expect{ subject.trax_defaults.uuid_prefix=(prefix) }.to raise_error
        end
      end
    end
  end
end
