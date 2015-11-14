require 'spec_helper'
describe ::Trax::Model::Mixins::StiEnum do
  subject{ ::Vehicle }

  it { expect(::Vehicle.new(:kind => :car).type).to eq "Vehicle::Car"}
  it { expect(::Vehicle.new(:kind => :truck).type).to eq "Vehicle::Truck"}
end
