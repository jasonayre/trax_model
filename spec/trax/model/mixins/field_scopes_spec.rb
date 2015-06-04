require 'spec_helper'

describe ::Trax::Model::Mixins::FieldScopes do
  subject{ ::Message.create(:title => "Whatever") }

  its(:status) { should eq "queued" }
end
