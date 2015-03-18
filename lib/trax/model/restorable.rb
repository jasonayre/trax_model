module Trax
  module Model
    module Restorable
      include ::Trax::Model::Mixin

      included do
        class_attribute :_restorable_config

        alias_method :destroy!, :destroy

        self._restorable_config = {
          :field => :is_deleted,
          :timestamp_field => :deleted_at,
          :hide_deleted => true
        }
      end

      module ClassMethods
        def setup_restorable!
          self.class_eval do
            if(self._restorable_config[:hide_deleted])
              default_scope { by_not_deleted }
            end

            ### Clear default deleted scope ###
            scope :by_is_deleted, lambda { |*|
              unscope(:where => self._restorable_config[:field]).where(self._restorable_config[:field] => true)
            }
            scope :by_not_deleted, lambda { |*|
              where(self._restorable_config[:field] => false)
            }

            default_value_for(self._restorable_config[:field]) { false }
          end
        end
      end

      def destroy
        self.update_attributes(self._restorable_config[:field] => true, self._restorable_config[:timestamp_field] => ::DateTime.now)
      end

      def restore
        self.update_attributes(self._restorable_config[:field] => false, self._restorable_config[:timestamp_field] => ::DateTime.now)
      end

      def self.apply_mixin(target, options)
        target._restorable_config.merge!(options)
        target.setup_restorable!
      end
    end
  end
end
