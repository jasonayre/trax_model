require 'spec_helper'

describe ::Trax::Model::Mixins::CachedFindBy do
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
  let(:vehicle_1) { ::Vehicle.create(:kind => :car, :manufacturer => ford, :cost => 20_000, :name => "pinto") }
  let(:vehicle_2) { ::Vehicle.create(:kind => :truck, :manufacturer => ford, :cost => 20_000, :name => "f150")}
  let(:vehicle_3) { ::Vehicle.create(:kind => :truck, :manufacturer => toyota, :cost => 15_000) }
  let(:person_1) { ::Person.create(:name => "jason", :vehicle_id => vehicle_1.id) }
  let(:person_2) { ::Person.create(:name => "steve", :vehicle_id => vehicle_1.id) }

  subject { ford }

  context ".cached_find_by" do
    before do
      person_1
      person_2
      subject
    end

    it "cache key exists" do
      ::Manufacturer.cached_find_by(:id => vehicle_1.manufacturer_id)

      cache_key = ::Trax::Model::CacheKey.new('manufacturers', '.find_by', {:id => vehicle_1.manufacturer_id})
      expect(::Trax::Model.cache.exist?(cache_key)).to eq true
    end

    it "caches relation" do
      vehicle_1
      expect(vehicle_1.cached_manufacturer.name).to eq subject.name

      man = ::Manufacturer.find(vehicle_1.cached_manufacturer.id)
      man.update_attributes(:name => "whatever")
      vehicle_1.reload
      expect(vehicle_1.cached_manufacturer.name).to eq "ford"
    end

    it "cache can be cleared by params" do
      vehicle_1
      expect(vehicle_1.cached_manufacturer.name).to eq subject.name

      man = ::Manufacturer.find(vehicle_1.cached_manufacturer.id)
      man.update_attributes(:name => "whatever")
      vehicle_1.reload
      expect(vehicle_1.cached_manufacturer.name).to eq "ford"
      ::Manufacturer.clear_cached_find_by(:id => man.id)
      expect(vehicle_1.cached_manufacturer.name).to eq "whatever"
    end
  end

  context ".cached_where" do
    subject { ::Vehicle.cached_where(:manufacturer_id => ford.id) }

    before do
      ford
      vehicle_1
      vehicle_2
      subject
    end

    it "cache key exists" do
      cache_key = ::Trax::Model::CacheKey.new('vehicles', '.where', {:manufacturer_id => ford.id})
      expect(::Trax::Model.cache.exist?(cache_key)).to eq true
    end

    it "caches result" do
      expect(subject[0].name).to eq vehicle_1.name
      vehicle_1.update_attributes(:name => "whatever")
      vehicle_1.reload
      expect(subject[0].name).to eq "pinto"
    end

    context ".clear_cached_where" do
      it do
        cache_key = ::Trax::Model::CacheKey.new('vehicles', '.where', {:manufacturer_id => ford.id})
        expect(::Trax::Model.cache.exist?(cache_key)).to eq true
        ::Vehicle.clear_cached_where(cache_key.search_params)
        expect(::Trax::Model.cache.exist?(cache_key)).to eq false
      end
    end
  end
end
