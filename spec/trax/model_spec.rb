require 'spec_helper'

describe ::Trax::Model do
  subject do
    ::Product
  end

  its(:trax_registry_key) { should eq "product" }
  its(:trax_defaults) { should be_a(::Trax::Model::Config) }
end
