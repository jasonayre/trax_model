require 'spec_helper'

describe ::UrlValidator do
  subject { ::Widget.create(:website => "http://www.initech.com") }

  its(:valid?) { should eq true }

  ["www.initech.com", "http://www.initech.com!"].each do |bad_url|
    it "should fail validation for #{bad_url}" do
      widget = ::Widget.create(:website => bad_url)
      widget.errors.messages.should have_key(:website)
    end
  end
end
