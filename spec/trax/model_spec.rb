require 'spec_helper'

describe ::Trax::Model do
  subject { ::Product }

  its(:trax_registry_key) { is_expected.to eq "product" }
  it { subject.unique_id_config.uuid_prefix }

  context "with model accessors for struct attribute" do
    let(:name) { "platypus" }
    subject { ::Animal.new(:name => name) }

    it { expect(::Animal.fields.constants).to_not include(:Characteristics) }

    context "inheriting model" do
      let(:fun_facts) { "is most like edible" }
      let(:characteristics) { {:fun_facts => fun_facts} }
      subject { ::Mammal.new(:name => name, :characteristics => characteristics) }

      it { expect(::Mammal.fields.constants).to include(:Characteristics) }

      its(:"characteristics.fun_facts") { is_expected.to eq(fun_facts) }
      it { expect(subject.characteristics.respond_to?(:fun_facts)).to eq(true) }

      context "model accessors" do
        its(:name) { is_expected.to eq(name) }
        its(:fun_facts) { is_expected.to eq(fun_facts) }
        it { expect(subject.respond_to?(:fun_facts)).to eq(true) }
      end
    end
  end
end
