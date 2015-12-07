require 'spec_helper'

describe ::Trax::Model::Attributes::Types::Struct, :postgres => true do
  subject{ ::Ecommerce::Products::MensShoes::Fields::CustomFields }

  it { expect(subject.new.primary_utility).to eq "Skateboarding" }
  it { expect(subject.new.sole_material).to eq "" }

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

      context "array property" do
        before(:all) do
          @item_1 = ::Ecommerce::Products::MensShoes.create(:custom_fields => { :tags => ['skateboarding'] })
          @item_2 = ::Ecommerce::Products::MensShoes.create(:custom_fields => { :tags => ['skateboarding', 'walking']})
          @item_3 = ::Ecommerce::Products::MensShoes.create(:custom_fields => { :tags => ['running']})
        end

        subject { ::Ecommerce::Products::MensShoes.all }

        it { expect(subject.by_tags('skateboarding')).to include(@item_1, @item_2) }
        it { expect(subject.by_tags('skateboarding')).to_not include(@item_3) }
        it { expect(subject.by_tags('running')).to include(@item_3) }
        it { expect(subject.by_tags('running')).to_not include(@item_1, @item_2) }
      end

      context "time property" do
        before(:all) do
          @timestamp_1 = "2013-01-01 07:00:00"
          @timestamp_2 = "2014-01-01 07:00:00"
          @timestamp_3 = "2015-01-01 07:00:00"
          @item_1 =  ::Ecommerce::Products::MensShoes.create(:custom_fields => { :last_received_at => @timestamp_1 })
          @item_2 =  ::Ecommerce::Products::MensShoes.create(:custom_fields => { :last_received_at => @timestamp_2 })
          @item_3 =  ::Ecommerce::Products::MensShoes.create(:custom_fields => { :last_received_at => @timestamp_3 })
        end

        subject { ::Ecommerce::Products::MensShoes.all }

        context "greater than" do
          it { expect(subject.by_last_received_at_gt(@timestamp_2)).to include(@item_3) }
          it { expect(subject.by_last_received_at_gt(@timestamp_2)).to_not include(@item_2, @item1) }
        end

        context "less than" do
          it { expect(subject.by_last_received_at_lt(@timestamp_2)).to include(@item_1) }
          it { expect(subject.by_last_received_at_lt(@timestamp_2)).to_not include(@item_3, @item_2) }
        end
      end

      context "numeric property" do
        before(:all) do
          @item_1 =  ::Ecommerce::Products::MensShoes.create(:custom_fields => { :in_stock_quantity => 1 })
          @item_2 =  ::Ecommerce::Products::MensShoes.create(:custom_fields => { :in_stock_quantity => 2 })
          @item_3 =  ::Ecommerce::Products::MensShoes.create(:custom_fields => { :in_stock_quantity => 3 })
        end

        subject { ::Ecommerce::Products::MensShoes.all }


        context "less than" do
          it { expect(subject.by_quantity_in_stock_lt(2)).to include(@item_1) }
          it { expect(subject.by_quantity_in_stock_lt(2)).to_not include(@item_2, @item_3) }

          context "or equal" do
            it { expect(subject.by_quantity_in_stock_lte(2)).to include(@item_1, @item_2) }
            it { expect(subject.by_quantity_in_stock_lt(2)).to_not include(@item_3) }
          end
        end

        context "greater than" do
          it { expect(subject.by_quantity_in_stock_gt(2)).to include(@item_3) }
          it { expect(subject.by_quantity_in_stock_gt(2)).to_not include(@item_2, @item_1) }

          context "or equal" do
            it { expect(subject.by_quantity_in_stock_gte(2)).to include(@item_3, @item_2) }
            it { expect(subject.by_quantity_in_stock_gte(2)).to_not include(@item_1) }
          end
        end

        context "equal" do
          it {
            values = subject.by_quantity_in_stock_eq(2).map(&:custom_fields).map(&:in_stock_quantity)
            expect(values).to include(2)
          }
          it {
            values = subject.by_quantity_in_stock_eq(2).map(&:custom_fields).map(&:in_stock_quantity)
            expect(values).to_not include(1, 3)
          }
        end
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
