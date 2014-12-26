require 'spec_helper'

describe ::Trax::Model::STI::Attributes do

  before do
    SwinglineStapler.sti_attribute(:owner)
  end

  context "delegation" do
    subject{ ::SwinglineStapler.new(:owner => "Milton Waddums") }

    its(:owner) { should eq "Milton Waddums" }
  end

end
