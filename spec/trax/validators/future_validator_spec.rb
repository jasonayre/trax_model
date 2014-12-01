require 'spec_helper'

describe ::FutureValidator do
  subject { ::Message.create(:deliver_at => (::DateTime.now + 1.days)) }

  its(:valid?) { should eq true }

  [(DateTime.now - 1.days)].each do |past_date|
    it "should fail validation for #{past_date}" do
      widget = ::Message.create(:deliver_at => past_date)
      widget.errors.messages.should have_key(:deliver_at)
    end
  end
end
