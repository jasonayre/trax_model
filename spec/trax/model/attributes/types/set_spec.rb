require 'spec_helper'

describe ::Trax::Model::Attributes::Types::Set, :postgres => true do
  subject{ ::Ecommerce::Vote.new(:upvoter_ids => [1, 2], :downvoter_ids => [3, 4, 5] )}

  it { expect(subject.upvoter_ids.__getobj__).to be_a(::Set) }
  it { expect(subject.upvoter_ids).to include(1) }

  context "attribute definition" do
    subject { ::Ecommerce::Vote::Fields::UpvoterIds.new }
    it { expect(subject.__getobj__).to be_a(::Set) }
  end

  context "loading from database" do
    it {
      subject.save
      test_subject = subject.reload
      expect(test_subject.upvoter_ids).to include(1)
    }
  end

  context "does not allow duplicate values" do
    it {
      subject.upvoter_ids << 1
      expect(subject.upvoter_ids.length).to eq 2
    }
  end

  context "dirty tracking" do
    it {
      subject.save
      subject.upvoter_ids = [2,3]
      expect(subject.upvoter_ids_was).to eq ::Set.new([1,2])
    }
  end

  context "setting value" do
    context "already a set" do
      let(:val) { ::Ecommerce::Vote::Fields::UpvoterIds.new([1, 2]) }
      subject { ::Ecommerce::Vote.new(:upvoter_ids => val) }
      it { expect(subject.upvoter_ids).to eq ::Set.new([1,2]) }
      it { expect(subject.upvoter_ids).to be_a(::Ecommerce::Vote::Fields::UpvoterIds) }
    end
  end

  #note: only supports string values for scopes at the moment
  #also note: I think this is the ideal api for the future.
  #I.e. define a scope on the model, by referencing the field directly.
  context "relations" do
    let!(:record_one) {
      ::Ecommerce::Vote.create(:upvoter_ids => ['1', '2'], :downvoter_ids => ['3', '4', '5'] )
    }
    let!(:record_two) {
      ::Ecommerce::Vote.create(:upvoter_ids => ['3', '4'], :downvoter_ids => ['6', '7', '8'] )
    }
    it {
      expect(
        ::Ecommerce::Vote::Fields::UpvoterIds.contains("1")
      ).to include record_one
    }
    it {
      expect(
        ::Ecommerce::Vote::Fields::UpvoterIds.contains("1")
      ).to_not include record_two
    }
    it {
      expect(
        ::Ecommerce::Vote::Fields::UpvoterIds.contains("4")
      ).to include record_two
    }
    it {
      expect(
        ::Ecommerce::Vote::Fields::UpvoterIds.contains("4")
      ).to_not include record_one
    }
  end
end
