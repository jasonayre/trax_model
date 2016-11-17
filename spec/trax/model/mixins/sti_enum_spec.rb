require 'spec_helper'
describe ::Trax::Model::Mixins::StiEnum do
  subject{ ::Vehicle }

  it { expect(::Vehicle.new(:kind => :car).type).to eq "Vehicles::Car" }
  it { expect(::Vehicle.new(:kind => :truck).type).to eq "Vehicles::Truck" }
  it { expect(::Vehicles::Car.new.kind.to_sym).to eq :car }
  it { expect(::Vehicles::Truck.new.kind.to_sym).to eq :truck }

  context "kind changes" do
    subject { ::Vehicle.new(:kind => :truck) }

    it {
      expect(subject.type).to eq "Vehicles::Truck"
      subject.kind = :car
      expect(subject.type).to eq "Vehicles::Car"
    }
  end

  context "type changes" do
    subject { ::Vehicles::Car.new }

    it {
      expect(subject.type).to eq "Vehicles::Car"
      subject.type = "Vehicles::Truck"
      expect(subject.kind.to_sym).to eq :truck
    }
  end
end
