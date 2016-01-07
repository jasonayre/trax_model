require 'spec_helper'

describe ::Trax::Model::Mixins::CachedMethods do
  before(:all) do
    ::ActiveRecord::Base.logger = ::Logger.new(::STDOUT)
  end

  before { ::Vehicle.destroy_all }

  let(:ford) { ::Manufacturer.create(:name => "ford", :url => "ford.com") }
  let(:toyota) { ::Manufacturer.create(:name => "toyota", :url => "toyota.com") }
  let(:vehicle_1) { ::Vehicle.create(:kind => :car, :manufacturer => ford, :cost => 20_000) }
  let(:vehicle_2) { ::Vehicle.create(:kind => :truck, :manufacturer => ford, :cost => 20_000) }

  subject{ ::Manufacturer }

  context "cached_instance_methods" do
    subject { ford }

    it "cache key exists" do
      subject.cached_vehicles
      expect(::Rails.cache.exist?("#{subject.id}/instance/vehicles", :namespace => "manufacturer")).to eq true
    end

    it "caches instance method result" do
      vehicle_1
      expect(subject.cached_vehicles.map(&:id).length).to eq 1
      new_vehicle = ::Vehicle.create(:kind => :car, :manufacturer => ford)
      subject.reload
      expect(subject.cached_vehicles.map(&:id).length).to eq 1
    end

    it "instance method result cache can be cleared" do
      vehicle_1
      expect(subject.cached_vehicles.map(&:id).length).to eq 1
      new_vehicle = ::Vehicle.create(:kind => :car, :manufacturer => ford)
      subject.reload
      expect(subject.cached_vehicles.map(&:id).length).to eq 1
      subject.clear_cached_vehicles
      expect(subject.cached_vehicles.map(&:id).length).to eq 2
    end
  end

  context "cached_class_methods" do
    subject { ::Manufacturer }

    before do
      subject.clear_cached_total_cost_of_vehicles_for_all_manufacturers
    end

    it "cache key exists" do
      subject.cached_total_cost_of_vehicles_for_all_manufacturers
      expect(::Rails.cache.exist?("total_cost_of_vehicles_for_all_manufacturers", :namespace => "manufacturer/class")).to eq true
      expect(::Trax::Model.cache.exist?("total_cost_of_vehicles_for_all_manufacturers", :namespace => "manufacturer/class")).to eq true
    end

    it "caches class methods" do
      vehicle_1
      expect(subject.cached_total_cost_of_vehicles_for_all_manufacturers).to eq 20_000
      vehicle_2
      expect(subject.cached_total_cost_of_vehicles_for_all_manufacturers).to eq 20_000
    end

    it "class method result cache can be cleared" do
      vehicle_1
      expect(subject.cached_total_cost_of_vehicles_for_all_manufacturers).to eq 20_000
      vehicle_2
      expect(subject.cached_total_cost_of_vehicles_for_all_manufacturers).to eq 20_000
      subject.clear_cached_total_cost_of_vehicles_for_all_manufacturers
      expect(subject.cached_total_cost_of_vehicles_for_all_manufacturers).to eq 40_000
    end
  end

  context "shared cache store" do
    it { expect(::Trax::Model.cache).to eq ::Vehicle._cached_methods_store }
    it { expect(::Vehicle._cached_methods_store).to eq ::Manufacturer._cached_methods_store }
  end
end
