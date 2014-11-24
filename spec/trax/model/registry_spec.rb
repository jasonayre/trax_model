require 'spec_helper'

describe ::Trax::Model::Registry do
  subject{ described_class }

  it "should have registered product model" do
    subject.key?(:product).should be true
  end

end
