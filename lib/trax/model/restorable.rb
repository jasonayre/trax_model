module Trax
  module Model
    module Restorable
      extend ::Trax::Model::Mixin

      define_configuration_options! do
        option :field, :default => :is_deleted
        option :timestamp_field, :default => :deleted_at
        option :hide_deleted, :default => true
        option :alias_destroy, :default => true
      end

      included do
        define_configuration_options!(:restorable) do
          option :field, :default => ::Trax::Model::Restorable.config.field
          option :timestamp_field, :default => ::Trax::Model::Restorable.config.timestamp_field
          option :hide_deleted, :default => ::Trax::Model::Restorable.config.hide_deleted
          option :alias_destroy, :default => ::Trax::Model::Restorable.config.alias_destroy
        end
      end

      module ClassMethods
        def setup_restorable!
          self.class_eval do
            if(self.restorable_config.hide_deleted)
              default_scope { by_not_deleted }
            end

            if(self.restorable_config.alias_destroy)
              alias_method :destroy!, :destroy
            end

            ### Clear default deleted scope ###
            scope :by_is_deleted, lambda { |*|
              unscope(:where => self.restorable_config.field).where(self.restorable_config.field => true)
            }
            scope :by_not_deleted, lambda { |*|
              where(self.restorable_config.field => false)
            }

            default_value_for(self.restorable_config.field) { false }
          end
        end
      end

      def destroy
        self.update_attributes(self.class.restorable_config.field => true, self.class.restorable_config.timestamp_field => ::DateTime.now)
      end

      def restore
        self.update_attributes(self.class.restorable_config.field => false, self.class.restorable_config.timestamp_field => ::DateTime.now)
      end

      def self.apply_mixin(target, options)
        target.restorable_config.merge!(options)

        target.setup_restorable!
      end
    end
  end
end
