require 'spec_helper'

describe ::Trax::Model::Attributes::Types::Json, :postgres => true do
  subject{ ::Ecommerce::Products::MensShoes::Fields::CustomFields }

  it { expect(subject.new.primary_utility).to eq "Skateboarding" }
  it { expect(subject.new.sole_material).to eq "" }

  context "model" do
    subject { ::Ecommerce::Products::MensShoes.new }

    context "default values" do
      it { subject.custom_fields.size.should eq :mens_9 }
    end

    context "search scopes" do
      context "enum property" do
        [ :mens_6, :mens_7, :mens_10 ].each_with_index do |enum_name|
          let!(enum_name) do
            ::Ecommerce::Products::MensShoes.create(:custom_fields => { :size => enum_name })
          end
        end
        subject { ::Ecommerce::Products::MensShoes.all }

        it { expect(subject.by_custom_fields_size(:mens_6, :mens_7)).to include(mens_6, mens_7) }
        it { expect(subject.by_custom_fields_size(:mens_6, :mens_7)).to_not include(mens_10) }
      end

      context "boolean property" do
        [ :mens_6, :mens_7, :mens_10 ].each_with_index do |enum_name|
          let!(enum_name) do
            ::Ecommerce::Products::MensShoes.create(:custom_fields => { :size => enum_name })
          end
        end

        subject { ::Ecommerce::Products::MensShoes.all }

        it { expect(subject.by_custom_fields_size(:mens_6, :mens_7)).to include(mens_6, mens_7) }
        it { expect(subject.by_custom_fields_size(:mens_6, :mens_7)).to_not include(mens_10) }
      end
    end

    context "dirty attributes" do
      subject { ::Ecommerce::Products::MensShoes.create(:custom_fields => { :size => :mens_6 }) }

      context "it tracks changes providing the human readable name" do
        before do
          subject.custom_fields.size = :mens_7
        end

        it { expect(subject.changes["custom_fields"][0]["size"]).to eq :mens_6 }
        it { expect(subject["custom_fields"]["size"]).to eq :mens_7 }
        it { expect(subject.changed_attributes["custom_fields"]["size"]).to eq :mens_6 }
      end
    end

    context "validation" do
      let(:subject_attributes) { {} }
      subject { ::Ecommerce::ShippingAttributes.create(subject_attributes) }

      context "invalid struct attribute" do
        subject { ::Ecommerce::ShippingAttributes.create(subject_attributes) }

        let(:subject_attributes) { { :specifics => {:cost => "asdasd", :dimensions => {}}} }

        it { expect(subject.valid?).to eq false }
        it { expect(subject.errors.messages).to have_key(:"specifics.cost") }
      end

      context "valid struct attribute" do
        let(:subject_attributes) { { :specifics => { :cost => "asdasdasdasdasd", :dimensions => {}}} }

        it { expect(subject.valid?).to eq true}
      end
    end
  end
end
