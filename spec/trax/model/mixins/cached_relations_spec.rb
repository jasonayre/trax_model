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

  let(:ford) { ::Manufacturer.create(:name => "ford", :url => "ford.com", :subscriber_id => subscriber.id) }
  let(:toyota) { ::Manufacturer.create(:name => "toyota", :url => "toyota.com", :subscriber_id => subscriber.id) }
  let(:vehicle_1) { ::Vehicle.create(:kind => :car, :manufacturer => ford, :cost => 20_000, :name => "pinto") }
  let(:vehicle_2) { ::Vehicle.create(:kind => :truck, :manufacturer => ford, :cost => 20_000, :name => "f150") }
  let(:vehicle_3) { ::Vehicle.create(:kind => :truck, :manufacturer => toyota, :cost => 15_000) }

  subject{ ford }

  context ".cached_belongs_to" do
    before do
      subject.cached_subscriber
    end

    it "cache key exists" do
      cache_key = ::Trax::Model::CacheKey.new('subscribers', '.find_by', {:id => subject.subscriber_id} )
      expect(::Trax::Model.cache.exist?(cache_key)).to eq true
    end

    it "caches relation" do
      expect(subject.cached_subscriber.name).to eq subscriber.name
      _subscriber = ::Subscriber.find(subscriber.id)
      _subscriber.update_attributes(:name => 'whatever')
      expect(subject.cached_subscriber.name).to eq subscriber.name
    end

    it "clears cached belongs to relation" do
      expect(subject.cached_subscriber.name).to eq subscriber.name
      _subscriber = ::Subscriber.find(subscriber.id)
      _updated_subscriber_name = 'whatever'
      _subscriber.update_attributes(:name => _updated_subscriber_name)
      expect(subject.cached_subscriber.name).to eq subscriber.name
      subject.clear_cached_subscriber
      expect(subject.cached_subscriber.name).to eq _updated_subscriber_name
    end
  end

  context ".cached_has_many" do
    before do
      ford
      toyota
    end

    subject!{ subscriber.cached_manufacturers }

    it "cache key exists" do
      cache_key = ::Trax::Model::CacheKey.new('manufacturers', '.where', {:subscriber_id => subscriber.id} )
      expect(::Trax::Model.cache.exist?(cache_key)).to eq true
    end

    it "caches relation" do
      expect(subject).to eq subscriber.manufacturers
      first_manufacturer_name = subject.first.name

      expect(subject.first.name).to eq subscriber.manufacturers.first.name
      _manufacturer = ::Manufacturer.find(subject.first.id)
      _manufacturer.update_attributes(:name => 'whatever')
      expect(subject.first.name).to eq first_manufacturer_name
    end

    it "clears cached has many relation" do
      expect(subject).to eq subscriber.manufacturers
      first_manufacturer_name = subject.first.name
      updated_manufacturer_name = 'whatever'

      expect(subject.first.name).to eq subscriber.manufacturers.first.name
      _manufacturer = ::Manufacturer.find(subject.first.id)
      _manufacturer.update_attributes(:name => updated_manufacturer_name)
      expect(subject.first.name).to eq first_manufacturer_name
      subscriber.clear_cached_manufacturers
      expect(subscriber.cached_manufacturers.first.name).to eq updated_manufacturer_name
    end
  end
end
