require 'spec_helper'

describe ::Trax::Model::Freezable do
  subject{ ::Message.create(:subject => "Whatever") }

  its(:status) { should eq "queued" }

  context "in frozen state" do
    subject { ::Message.create(:subject => "Whatever", :status => :delivered) }

    it do
      subject.subject = "somethingelse"
      subject.save

      subject.errors.messages[:subject].should include("Cannot be modified")
    end
  end
end
