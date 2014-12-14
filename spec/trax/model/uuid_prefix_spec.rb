require 'spec_helper'
describe ::Trax::Model::UUIDPrefix do
  subject{ described_class.new('1a') }

  describe ".all" do
    it { described_class.all.should include("a1") }
    it { described_class.all.first.should eq "0a" }
    it { described_class.all.last.should eq "f9" }
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
end
