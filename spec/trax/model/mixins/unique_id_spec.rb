require 'spec_helper'
describe ::Trax::Model::Mixins::UniqueId do
  subject{ ::Product }

  its(:uuid_prefix) { should be_instance_of(::Trax::Model::UUIDPrefix) }

  context "Class Methods" do
    describe ".generate_uuid" do
      it "returns new uuid build with prefix" do
        expect(subject.generate_uuid).to start_with("1a")
      end
    end

    describe ".new" do
      subject { Product.new }
      its(:uuid) { is_expected.to start_with("1a") }
    end

    describe ".uuid_prefix" do
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

  context "Instance Methods" do
    describe "#generate_uuid!" do
      subject { ::Product.new }
      its(:uuid) {
        current_uuid = subject.uuid
        subject.generate_uuid!
        expect(subject.uuid).to_not eq current_uuid
      }
    end
  end
end
