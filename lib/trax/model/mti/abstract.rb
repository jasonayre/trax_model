module Trax
  module Model
    module MTI
      module Abstract
        extend ::ActiveSupport::Concern

        included do
          class_attribute :mti_config

          self.abstract_class = true
          self.mti_config = ::ActiveSupport::HashWithIndifferentAccess.new({
            :foreign_key => :id
          })

          scope :records, lambda{
            map(&:entity)
          }
        end

        module ClassMethods
          def inherited(subklass)
            super(subklass)

            subklass.after_create do |record|
              entity_model = mti_config[:class_name].constantize.new

              record.attributes.each_pair do |k,v|
                entity_model.__send__("#{k}=", v) if entity_model.respond_to?(k)
              end

              entity_model.save
            end

            subklass.after_update do |record|
              entity_model = record.entity

              if record.changed.any?
                record.changes.each_pair do |k,v|
                  entity_model.__send__("#{k}=", v[1]) if entity.respond_to?(:"#{k}")
                end
              end

              entity_model.save if entity_model.changed.any?
            end

            subklass.after_destroy do |record|
              entity_model = record.entity

              entity_model.destroy
            end
          end

          def entity_model(options)
            valid_options = options.assert_valid_keys(:class_name, :foreign_key)

            mti_config.merge!(valid_options)

            self.has_one(:entity, mti_config.symbolize_keys)
            self.accepts_nested_attributes_for(:entity)
          end
        end
      end
    end
  end
end
