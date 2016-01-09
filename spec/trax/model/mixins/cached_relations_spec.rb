require 'spec_helper'

describe ::Trax::Model::Mixins::CachedRelations do
  before(:all) do
    ::ActiveRecord::Base.logger = ::Logger.new(::STDOUT)
  end

  before { ::Vehicle.destroy_all }
  before { ::Manufacturer.destroy_all }
  before { ::Subscriber.destroy_all }
  before { ::Person.destroy_all }
  before { ::Trax::Model.cache.clear }

  let(:subscriber) { ::Subscriber.create(:name => "automatch_usa") }
  let(:subscriber_2) { ::Subscriber.create(:name => "larryhmiller") }

  let(:ford) { ::Manufacturer.create(:name => "ford", :url => "ford.com", :subscriber_id => subscriber.id) }
  let(:toyota) { ::Manufacturer.create(:name => "toyota", :url => "toyota.com", :subscriber_id => subscriber_2.id) }
  let(:vehicle_1) { ::Vehicle.create(:kind => :car, :manufacturer => ford, :cost => 20_000) }
  let(:vehicle_2) { ::Vehicle.create(:kind => :truck, :manufacturer => ford, :cost => 20_000) }
  let(:vehicle_3) { ::Vehicle.create(:kind => :truck, :manufacturer => toyota, :cost => 15_000) }
  let(:person_1) { ::Person.create(:name => "jason", :vehicle_id => vehicle_1.id) }
  let(:person_2) { ::Person.create(:name => "steve", :vehicle_id => vehicle_1.id) }

  subject{ ::Manufacturer }

  context "cached_belongs_to" do
    subject { vehicle_1 }

    it "cache key exists" do
      expect(person_1.cached_vehicle.cost).to eq 20_000
      subject.update_attributes(:cost => 30_000)
      expect(person_1.cached_vehicle.cost).to eq 20_000
    end

    it "instance method result cache can be cleared" do
      subject
      expect(person_1.cached_vehicle.cost).to eq 20_000
      subject.update_attributes(:cost => 30_000)
      expect(person_2.cached_vehicle.cost).to eq 20_000
      subject.reload
      expect(person_2.cached_vehicle.cost).to eq 20_000
      expect(subject.cost).to eq 30_000
    end

    context "with scope" do
      subject { ford }

      it "cache key exists" do
        vehicle_1

        expect(vehicle_1.cached_manufacturer).to eq subject
        expect(::Trax::Model.cache.exist?(*[subject.id, { :subscriber_id => subscriber.id }])).to eq true
      end

      it "caches relation" do
        vehicle_1
        expect(vehicle_1.cached_manufacturer.name).to eq subject.name

        man = ::Manufacturer.find(vehicle_1.cached_manufacturer.id)
        man.update_attributes(:name => "whatever")
        vehicle_1.reload
        expect(vehicle_1.cached_manufacturer.name).to eq "ford"
      end

      it "relation cache can be cleared" do
        vehicle_1
        expect(vehicle_1.cached_manufacturer.name).to eq subject.name

        man = ::Manufacturer.find(vehicle_1.cached_manufacturer.id)
        man.update_attributes(:name => "whatever")
        vehicle_1.reload
        expect(vehicle_1.cached_manufacturer.name).to eq "ford"
        vehicle_1.clear_cached_manufacturer
        expect(vehicle_1.cached_manufacturer.name).to eq "whatever"
      end
    end
  end
end
