require 'spec_helper'

describe ::Trax::Model::Attributes::Types::Array, :postgres => true do
  subject{ ::Ecommerce::Vote.new(:upvoter_ids_array => ["1", "2"], :downvoter_ids_array => ["3", "4", "5"] )}

  it { expect(subject.upvoter_ids.__getobj__).to be_a(::Array) }
  it { expect(subject.upvoter_ids).to include("1") }

  context "attribute definition" do
    subject { ::Ecommerce::Vote::Fields::UpvoterIdsArray.new }
    it { expect(subject.__getobj__).to be_a(::Array) }
  end

  context "loading from database" do
    it {
      subject.save
      test_subject = subject.reload
      expect(test_subject.upvoter_ids_array).to include("1")
    }
  end

  context "does not allow duplicate values" do
    it {
      subject.upvoter_ids_array << "1"
      expect(subject.upvoter_ids_array.length).to eq 2
    }
  end

  context "dirty tracking" do
    it {
      subject.save
      subject.upvoter_ids = ["2","3"]
      expect(subject.upvoter_ids_was).to eq ::Array.new(["1","2"])
    }
  end

  context "setting value" do
    context "already a set" do
      let(:val) { ::Ecommerce::Vote::Fields::UpvoterIdsArray.new(["1", "2"]) }
      subject { ::Ecommerce::Vote.new(:upvoter_ids_array => val) }
      it { expect(subject.upvoter_ids_array).to eq ::Set.new(["1","2"]) }
      it { expect(subject.upvoter_ids_array).to be_a(::Ecommerce::Vote::Fields::UpvoterIdsArray) }
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
      ::Ecommerce::Vote.create(:upvoter_ids => ['3', '4', '9'], :downvoter_ids => ['6', '7', '8', '20'] )
    }
    it {
      expect(
        ::Ecommerce::Vote::Fields::UpvoterIdsArray.contains("1")
      ).to include record_one
    }
    it {
      expect(
        ::Ecommerce::Vote::Fields::UpvoterIdsArray.does_not_contain("1")
      ).to_not include record_one
    }
    it {
      expect(
        ::Ecommerce::Vote::Fields::UpvoterIdsArray.contains("1")
      ).to_not include record_two
    }
    it {
      expect(
        ::Ecommerce::Vote::Fields::UpvoterIdsArray.contains("4")
      ).to include record_two
    }
    it {
      expect(
        ::Ecommerce::Vote::Fields::UpvoterIdsArray.contains("4")
      ).to_not include record_one
    }

    context "length methods" do
      subject { ::Ecommerce::Vote::Fields::UpvoterIdsArray }
      context "length_eq" do
        it { expect(subject.length_eq(2)).to include record_one }
        it { expect(subject.length_eq(2)).to_not include record_two }
      end

      context "length_gt" do
        it { expect(subject.length_gt(2)).to include record_two}
        it { expect(subject.length_gt(2)).to_not include record_one }
      end

      context "length_lt" do
        it { expect(subject.length_lt(3)).to include record_one}
        it { expect(subject.length_lt(3)).to_not include record_two }
      end

      context "length_gte" do
        it { expect(subject.length_gte(2)).to include(record_one, record_two) }
      end

      context "length_lte" do
        it { expect(subject.length_lte(1)).to_not include(record_one, record_two) }
      end
    end
  end
end
