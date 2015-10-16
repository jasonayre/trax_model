require 'spec_helper'

describe ::Trax::Model::Attributes::Types::Struct, :postgres => true do
  subject{ ::Ecommerce::Products::MensShoes::Fields::CustomFields }

  it { expect(subject.new.primary_utility).to eq "Skateboarding" }
  it { expect(subject.new.sole_material).to eq nil }

  context "attribute definition" do
    subject { ::Ecommerce::ShippingAttributes.new }

    context "model_accessors (delegators)" do
      it {
        ::Ecommerce::ShippingAttributes.fields[:specifics].properties.each do |_property|
          expect(subject.__send__(_property)).to eq subject.specifics.__send__(_property)
        end
      }

      context "initializing model and setting delegated attributes directly", :delegated_attributes =>  { :cost => 5, :tax => 5, :delivery_time => "5 days" } do
        self::DELEGATED_ATTRIBUTES = { :cost => 5, :tax => 5, :delivery_time => "5 days" }

        subject{ |example| ::Ecommerce::ShippingAttributes.new(example.example_group::DELEGATED_ATTRIBUTES) }

        self::DELEGATED_ATTRIBUTES.each_pair do |k,v|
          it "#{k} should be set" do
            expect(subject.specifics.__send__(k)).to eq v
          end
        end
      end
    end
  end

  context "model" do
    subject { ::Ecommerce::Products::MensShoes.new }

    context "default values" do
      it { subject.custom_fields.size.should eq :mens_9 }
    end

    context "instance method defined within struct" do
      subject { ::Ecommerce::Products::MensShoes.new(:custom_fields => {:cost => 10, :price => 20, :number_of_sales => 5}) }
      it {
        expect(subject.custom_fields.total_profit).to eq 50
      }
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
        let(:subject_attributes) { { :specifics => { :cost => 1, :dimensions => { :length => 10 }}} }

        it { expect(subject.valid?).to eq true }
      end

      context "enum_property coercing" do
        context "valid enum value" do
          context "value is symbol" do
            let(:subject_attributes) { { :specifics => { :service => :usps } } }

            it { expect(subject.specifics.service.to_i).to eq 1 }
          end

          context "value is symbol" do
            let(:subject_attributes) { { :specifics => { :service => "usps" } } }

            it { expect(subject.specifics.service.to_i).to eq 1 }
          end
        end

        context "invalid enum attributes" do
          context "out of range integer" do
            let(:subject_attributes) { { :specifics => { :service => 20 } } }

            it { expect(subject.specifics.service).to eq nil }
          end

          context "non existent string" do
            let(:subject_attributes) { { :specifics => { :service => "sasdasd" } } }

            it { expect(subject.specifics.service).to eq nil }
          end
        end
      end
    end
  end
end
