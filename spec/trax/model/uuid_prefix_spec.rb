require 'spec_helper'
describe ::Trax::Model::UUIDPrefix do
  subject{ Trax::Model::UUIDPrefix.new('1a') }

  describe "#to_i" do
    {"1a" => 10, "2a" => 20, "9e" => 94, "8d" => 83, "0a" => 0, "0b" => 1, "f9" => 251}.each_pair do |prefix_string, assertion|
      it "#{prefix_string} should eq #{assertion}" do
        prefix = ::Trax::Model::UUIDPrefix.new(prefix_string)

        prefix.to_i.should eq assertion
      end
    end
  end

  describe ".all" do
    it { described_class.all.should include("9a") }
    it { described_class.all.length.should eq 120 }
  end

  describe ".build_from_integer" do
    it { described_class.build_from_integer(10).should eq "1a" }
  end

  describe "#next" do
    let(:test_subject) { Product.uuid_prefix }

    it { test_subject.next.should eq '1b' }

    context "lower to higher register transitions" do
      let(:test_subject) { ::Trax::Model::UUIDPrefix.new('9f') }
      it { test_subject.next.should eq 'a0'}
    end
  end

  describe "#previous" do
    let(:test_subject) { Product.uuid_prefix }

    it { test_subject.previous.should eq '0f' }
  end

  describe "#to_i" do
    context "when prefix in {int,str} order" do
      let(:test_subject) { Product.uuid_prefix }

      it { test_subject.to_i.should eq 10 }
    end
  end
end
