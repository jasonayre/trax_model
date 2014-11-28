module Trax
  module Model
    module Validators
      class Frozen < ActiveModel::Validator
        def validate(record)
          record.changed.any? do |field|
            record.errors[field] << "Cannot be modified"
          end
        end
      end
    end
  end
end
