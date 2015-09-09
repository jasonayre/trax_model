require 'spec_helper'

describe ::Trax::Model::Freezable do
  subject{ ::Message.create(:title => "Whatever") }

  its(:status) { should eq "queued" }

  context "in frozen state" do
    subject { ::Message.create(:title => "Whatever", :status => :delivered) }

    it do
      subject.title = "somethingelse"
      subject.save

      expect(subject.errors.messages[:title]).to include("Cannot be modified")
    end
  end
end
