require 'spec_helper'

describe ::Trax::Model::Restorable do
  subject{ ::Message.create(:title => "Whatever") }

  its(:deleted) { should be false }

  context "when destroyed" do
    it "should soft delete" do
      subject.destroy
      subject.deleted.should be true
    end

    it "should be restorable" do
      subject.destroy
      subject.restore
      subject.deleted.should be false
    end
  end

  context "scopes" do
    subject{ ::Message.create(:title => "My Message") }

    context ".default_scope" do
      it { Message.all.where_values_hash["deleted"].should eq false }

      it do
        subject
        Message.all.pluck(:id).should include(subject.id)
      end

      it do
        subject.destroy
        Message.all.pluck(:id).should_not include(subject.id)
      end
    end

    it ".by_is_deleted" do
      subject.destroy
      binding.pry
      Message.by_is_deleted.pluck(:id).should include(subject.id)
    end
  end
end
