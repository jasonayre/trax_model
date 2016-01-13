require 'spec_helper'

describe ::Trax::Model::CacheKey do
  subject{ described_class }

  context "cache key" do
    let(:fake_id) { 1 }
    let(:expires) { 2.hours }
    let(:cache_options) { {:expires_in => expires }}
    subject { ::Trax::Model::CacheKey.new("posts", :id => fake_id, :expires_in => expires) }
    it {
      expect(subject.first).to eq "posts"
    }
    it { expect(subject.options).to eq cache_options }
  end
end
