require 'spec_helper'

describe ::SubdomainValidator do
  subject { ::Widget.create(:subdomain => "something") }
  its(:valid?) { should eq true }

  ["bad!", "-asdasd", "www", "ac"].each do |bad_subdomain|
    it "should fail validation for #{bad_subdomain}" do
      widget = ::Widget.create(:subdomain => bad_subdomain)
      expect(widget.valid?).to eq false
    end
  end
end
