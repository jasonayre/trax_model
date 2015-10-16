require 'spec_helper'

describe ::Trax::Model::Attributes do
  subject{ described_class }

  describe ".register_attribute_type" do
    [:array, :boolean, :enum, :integer, :struct, :string, :uuid_array].each do |type|
      it "registers attribute type #{type}" do
        expect(subject.config.attribute_types).to have_key(type)
      end
    end
  end
end
