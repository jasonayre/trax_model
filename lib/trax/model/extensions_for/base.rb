module Trax
  module Model
    module ExtensionsFor
      module Base
        extend ::ActiveSupport::Concern

        module ClassMethods
          def field_name
            name.demodulize.underscore
          end

          def model_class
            @model_class ||= begin
              model_class_for_property(self)
            end
          end

          def model_class_for_property(property_klass)
            result = if property_klass.parent_definition.ancestors.include?(::ActiveRecord::Base)
              property_klass.parent_definition
            else
              model_class_for_property(property_klass.parent_definition)
            end

            result
          end
        end
      end
    end
  end
end
