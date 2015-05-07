require 'spec_helper'
describe ::Trax::Model::Struct do
  subject {
    ::StoreCategory.new(
      "name" => "watches",
      "meta_attributes" => {
        "description" => "Watches and stuff",
        "keywords" => [ 'nixon', 'vestal' ]
      }
    )
  }

  its("name") {  should eq "watches" }
  its("meta_attributes.description") { should eq "Watches and stuff" }
  its("meta_attributes.class") { should eq StoreCategory::MetaAttributesStruct }
end
