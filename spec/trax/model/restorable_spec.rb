require 'spec_helper'

describe ::Trax::Model::Restorable do
  subject{ ::Message.create(:title => "Whatever") }

  its(:deleted) { should be false }

  context "when destroyed" do
    it "should soft delete" do
      subject.destroy
      expect(subject.deleted).to be true
    end

    it "should be restorable" do
      subject.destroy
      subject.restore
      expect(subject.deleted).to be false
    end
  end

  context "scopes" do
    subject{ ::Message.create(:title => "My Message") }

    context ".default_scope" do
      it { Message.all.where_values_hash["deleted"].should eq false }

      it do
        subject
        expect(Message.all.pluck(:id)).to include(subject.id)
      end

      it do
        subject.destroy
        expect(Message.all.pluck(:id)).to_not include(subject.id)
      end
    end

    it ".by_is_deleted" do
      subject.destroy
      expect(Message.by_is_deleted.pluck(:id)).to include(subject.id)
    end
  end
end
