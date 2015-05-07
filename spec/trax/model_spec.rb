require 'spec_helper'

describe ::Trax::Model do
  subject { ::Product }

  its(:trax_registry_key) { should eq "product" }
  it { subject.unique_id_config.uuid_prefix }
end
