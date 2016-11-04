require 'spec_helper'

describe ::Trax::Model::CacheKey do
  let(:fake_id) { 1 }
  let(:expires) { 2.hours }
  let(:cache_options) { {:expires_in => expires } }
  let(:search_params) { {:id => fake_id} }
  let(:cache_key_params) { cache_options.merge(search_params) }
  subject{ described_class.new("posts", **cache_key_params) }

  it { expect(subject.first).to eq "posts" }
  it { expect(subject.options).to eq cache_options }
  it { expect(subject.to_s).to eq "posts/id/1" }

  context "order of params" do
    let(:search_params) { {:id => fake_id, :a => "b"} }
    it { expect(subject.to_s).to eq "posts/a/b/id/1" }

    context "does not matter" do
      let(:search_params) { {:a => "b", :id => fake_id} }
      it { expect(subject.to_s).to eq "posts/a/b/id/1" }
    end
  end
end
