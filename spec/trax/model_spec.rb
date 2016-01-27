require 'spec_helper'

describe ::Trax::Model do
  subject { ::Product }

  its(:trax_registry_key) { is_expected.to eq "product" }
  it { subject.unique_id_config.uuid_prefix }

  context "with model accessors for struct attribute" do
    it { expect(::Animal.fields.constants).to include(:Characteristics) }

    context "inheriting model" do
      let(:name) { "platypus" }
      let(:fun_facts) { ["is most like edible"] }
      let(:characteristics) { {:fun_facts => fun_facts} }
      subject { ::Mammal.create!(:name => name, :characteristics => characteristics) }

      it { expect(::Mammal.fields.constants).to include(:Characteristics) }

      #its(:name) { is_expected.to eq(name) }
      #its(:fun_facts) { is_expected.to eq(fun_facts) }
      #its(:characteristics) { is_expected.to eq(characteristics) }
      #it { expect(subject.respond_to?(:fun_facts)).to eq(true) }

      #its(:"characteristics.fun_facts") { is_expected.to eq(fun_facts) }
      #it { expect(subject.characteristics.respond_to?(:fun_facts)).to eq(true) }
      #it { binding.pry }
    end
  end
end
