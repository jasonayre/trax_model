require 'spec_helper'

describe ::Trax::Model::Attributes::Types::Enum do
  subject{ ::Products::MensShoes::Fields::Size }

  let(:shoe_size_integer_values) { (1..7).to_a }
  let(:names) { [:mens_6, :mens_7, :mens_8, :mens_9, :mens_10, :mens_11, :mens_12] }

  it { expect(subject.values).to eq shoe_size_integer_values }
  it { expect(subject.names.map(&:to_sym)).to eq names }

  context "model" do
    subject {
      ::Products::MensShoes.new
    }

    context "default value" do
      it { subject.size.should eq :mens_9 }
    end

    context "search scopes" do
      [ :mens_6, :mens_7, :mens_10 ].each_with_index do |enum_name|
        let!(enum_name) do
          ::Products::MensShoes.create(:size => enum_name)
        end
      end

      subject { ::Products::MensShoes.all }

      it { expect(subject.by_size(:mens_6, :mens_7)).to include(mens_6, mens_7) }
      it { expect(subject.by_size(:mens_6, :mens_7)).to_not include(mens_10) }
      it { expect(subject.fields[:size].eq(:mens_6)).to include(mens_6) }
      it { expect(subject.fields[:size].in(:mens_6)).to include(mens_6) }
      it { expect(subject.fields[:size].in(:mens_6, :mens_7)).to include(mens_6, mens_7) }
    end

    context "dirty attributes" do
      subject { ::Products::MensShoes.create(:size => :mens_6) }

      context "it tracks changes providing the human readable name" do
        before do
          subject.size = :mens_7
        end

        it do
          subject.size = :mens_7
          expect(subject.changes["size"]).to eq [:mens_6, :mens_7]
        end

        it { expect(subject.size_was).to eq :mens_6 }
      end
    end
  end
end
