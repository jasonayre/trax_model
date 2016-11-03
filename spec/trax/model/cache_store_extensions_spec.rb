require 'spec_helper'

describe ::Trax::Model::CacheStoreExtensions do
  before do
    ::Trax::Model.cache = ::ActiveSupport::Cache::MemoryStore.new
  end

  subject{ ::Trax::Model.cache }

  context "#fetch" do
    let(:cache_key) { ::Trax::Model::CacheKey.new("posts", :expires_in => 2.seconds) }
    it {
      subject.fetch(cache_key) { "one" }
      expect(subject.fetch(cache_key)).to eq "one"
      sleep(2)
      expect(subject.fetch(cache_key) { "two" }).to eq "two"
    }
  end
end
