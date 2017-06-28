module Trax
  module Model
    module Validators
      class AssociatedBubblingValidator < ::ActiveModel::EachValidator
        module ValidationHelperMethod
          def validates_associated_with_bubbling(*attr_names)
            validates_with ::Trax::Model::Validators::AssociatedBubblingValidator, _merge_attributes(attr_names)
          end
        end

        def validate_each(record, attribute, value)
          ((value.kind_of?(::Enumerable) || value.kind_of?(::ActiveRecord::Relation)) ? value : [value].compact).each do |v|
            unless v.valid?
              v.errors.full_messages.each do |msg|
                record.errors.add(attribute, msg, options.merge(:value => value))
              end
            end
          end
        end

        ::Trax::Model::Validators.register(self)
      end
    end
  end
end
