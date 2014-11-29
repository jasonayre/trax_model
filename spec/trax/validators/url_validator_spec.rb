require 'spec_helper'

describe ::UrlValidator do
  subject { ::Widget.create(:website => "blahblahblah") }

  its(:valid?) { should eq false }
end
