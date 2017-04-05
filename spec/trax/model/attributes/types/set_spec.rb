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
      ::Ecommerce::Vote.create(:upvoter_ids => ['3', '4', '9'], :downvoter_ids => ['6', '7', '8', '20'] )
    }
    it {
      expect(
        ::Ecommerce::Vote::Fields::UpvoterIds.contains("1")
      ).to include record_one
    }
    it {
      expect(
        ::Ecommerce::Vote::Fields::UpvoterIds.does_not_contain("1")
      ).to_not include record_one
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

    context "length methods" do
      subject { ::Ecommerce::Vote::Fields::UpvoterIds }
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

    context "Sets containing things" do
      let(:locations) { [{:country => :canada, :street_address => "Somewhere in quebec"} ] }
      subject { Ecommerce::User.create(:sign_in_locations => locations) }

      it {
        subject.reload
        expect(subject.sign_in_locations.first).to be_a(Ecommerce::SharedDefinitions::Fields::Location)
        expect(subject.sign_in_locations.first.country.to_i).to eq 2
      }

      context "setception (sets within a set)" do
        let(:session1) {
          [
            {:site => :website_1, :url => "https://whatever.com"},
            {:site => :website_1, :url => "https://whatever.com/products"}
          ]
        }
        let(:session2) {
          [
            {:site => :website_2, :url => "https://whatever.com"},
          ]
        }

        let(:sessions) {
          [session1, session2]
        }

        subject { Ecommerce::User.create(:shopping_cart_sessions => sessions) }

        it {
          subject.reload
          binding.pry
          expect(subject.shopping_cart_sessions[0][0]).to be_a(::Ecommerce::PageView)
        }

      end
    end
  end
end
