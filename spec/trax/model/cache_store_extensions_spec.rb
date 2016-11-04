require 'spec_helper'

describe ::Trax::Model::CacheStoreExtensions do
  before do
    ::Trax::Model.cache = ::ActiveSupport::Cache::MemoryStore.new
  end

  subject{ ::Trax::Model.cache }

  context "#fetch" do
    context "manually instantiated cache key" do
      let(:cache_key) { ::Trax::Model::CacheKey.new("posts", :expires_in => 10.seconds) }

      it do
        subject.fetch(cache_key) { "one" }
        expect(subject.fetch(cache_key, cache_key.options)).to eq "one"

        Timecop.freeze(Time.now + 20.seconds) do
          expect(subject.fetch(cache_key) { "two" }).to eq "two"
        end
      end
    end

    context "args/options passed directly to fetch" do
      it do
        subject.fetch("some_class", ".find", :id => 5, :expires_in => 10.seconds) { "one" }
        expect(subject.fetch("some_class", ".find", :id => 5)).to eq "one"

        Timecop.freeze(Time.now + 20.seconds) do
          expect(subject.fetch("some_class", ".find", :id => 5)).to eq nil
        end
      end
    end
  end
end
