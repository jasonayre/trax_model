module Trax
  module Model
    module Mixins
      module Restorable
        extend ::Trax::Model::Mixin

        module DeferredInstanceMethods
          def destroy
            self.update(self.class.restorable_config.field => true, self.class.restorable_config.timestamp_field => ::DateTime.now)
          end
        end

        define_configuration_options! do
          option :field, :default => :is_deleted
          option :timestamp_field, :default => :deleted_at
          option :hide_deleted, :default => true
          option :alias_destroy, :default => true
        end

        included do
          define_configuration_options!(:restorable) do
            option :field, :default => ::Trax::Model::Mixins::Restorable.config.field
            option :timestamp_field, :default => ::Trax::Model::Mixins::Restorable.config.timestamp_field
            option :hide_deleted, :default => ::Trax::Model::Mixins::Restorable.config.hide_deleted
            option :alias_destroy, :default => ::Trax::Model::Mixins::Restorable.config.alias_destroy
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
              if(self.restorable_config.hide_deleted)
                scope :by_is_deleted, lambda { |*|
                  unscope(:where => self.restorable_config.field).where(self.restorable_config.field => true)
                }
              else
                scope :by_is_deleted, lambda { |*|
                  where(self.restorable_config.field => true)
                }
              end

              if(self.restorable_config.hide_deleted)
                scope :by_not_deleted, lambda { |*|
                  where(self.restorable_config.field => false)
                }
              else
                scope :by_not_deleted, lambda { |*|
                  where(self.restorable_config.field => [nil, false])
                }
              end

              default_value_for(self.restorable_config.field) { false }
            end
          end
        end

        def restore
          self.update(self.class.restorable_config.field => false, self.class.restorable_config.timestamp_field => ::DateTime.now)
        end

        def self.apply_mixin(target, options)
          target.restorable_config.merge!(options)
          target.setup_restorable!
          target.include(::Trax::Model::Mixins::Restorable::DeferredInstanceMethods)
        end
      end
    end
  end
end
