require 'spec_helper'
describe ::Trax::Model::Config do
  describe "uuid_prefix" do
    context "bad prefixes" do
      ["a", "1p", "a1a", "bl", "1", "111"].each do |prefix|
        it "raises error when passed hex incompatible prefix #{prefix}" do
          expect{ described_class.new(:uuid_prefix => prefix).to_raise_error }
        end
      end
    end
  end
end
