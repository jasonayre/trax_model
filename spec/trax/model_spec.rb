require 'spec_helper'

describe ::Trax::Model do
  subject do
    ::Product
  end

  its(:trax_registry_key) { should eq "product" }

  describe "uuid_prefix" do
    context "bad prefixes" do
      ["a", "1p", "a1a", "bl", "1", "111"].each do |prefix|
        it "raises error when passed hex incompatible prefix #{prefix}" do
          expect{ subject.uuid_prefix=(prefix) }.to raise_error
        end
      end
    end
  end
end
