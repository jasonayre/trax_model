require 'spec_helper'

describe ::Trax::Model::UUID do
  let(:uuid_string) { SecureRandom.generate(40)}
  subject{ described_class }

  it "should have registered product model" do
    subject.key?(:product).should be true
  end

end
