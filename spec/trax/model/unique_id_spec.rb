require 'spec_helper'
describe ::Trax::Model::UniqueId do
  subject{ ::Product }

  its(:uuid_prefix) { should be_instance_of(::Trax::Model::UUIDPrefix) }

  describe "uuid_prefix" do
    context "bad prefixes" do
      ["a", "1p", "a1a", "bl", "1", "111"].each do |prefix|
        let(:test_subject) { ::Trax::Core::NamedClass.new("Product::Asdfg#{prefix}", subject)}

        it "raises error when passed hex incompatible prefix #{prefix}" do
          expect{ test_subject.mixins(:unique_id => {:uuid_prefix => prefix})}.to raise_error(::Trax::Core::Errors::ConfigurationError)
        end
      end
    end
  end
end
