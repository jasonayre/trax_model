require 'spec_helper'

describe ::EmailValidator do
  subject { ::Widget.create(:email_address => "good@email.com") }
  ["jason@somewhere", "jason", "@gmail.com", "jason@something.something.com", "123456@123.com", "!!!@!!!.com"].each do |bad_email|
    it "should fail validation for #{bad_email}" do
      widget = ::Widget.create(:email_address => bad_email)
      widget.valid?.should eq false
    end
  end
end
