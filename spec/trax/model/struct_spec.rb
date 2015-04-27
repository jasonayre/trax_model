require 'spec_helper'
describe ::Trax::Model::Struct do

  class StoreCategory < ::Trax::Model::Struct
    property "name"

    struct_property "meta_attributes" do
      property "description"
      property "keywords"
    end
  end

  subject {

    binding.pry
    StoreCategory.new({
      "name" => "watches",
      "meta_attributes" => {
        "description" => "Watches and stuff",
        "keywords" => [ 'nixon', 'vestal' ]
      }
    })
  }

  its("name") {  should eq "watches" }
  its("meta_attributes.description") {
    binding.pry

    should eq "Watches and stuff" }

    its("meta_attributes.description.class") { should eq ::Trax::Model::Struct }

end
