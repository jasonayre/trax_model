module Trax
  module Model
    module Freezable
      extend ::Trax::Model::Mixin

      included do
        class_attribute :freezable_fields
        self.freezable_fields = ::ActiveSupport::OrderedOptions.new
      end

      module ClassMethods
        def freezable_by_enum(options = {})
          freezable_fields.merge!(options)
          define_frozen_validators_for_enum(options)
        end

        def define_frozen_validators_for_enum(options)
          self.class_eval do
            options.each_pair do |enum_method, frozen_states|
              validates_with ::FrozenValidator, :if => lambda { |record|
                frozen_states.any?{ |state| state == :"#{record.send(enum_method)}" } && !record.changed.include?("#{enum_method}")
              }
            end
          end
        end
      end
    end
  end
end
