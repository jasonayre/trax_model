module Trax
  module Model
    module Mixins
      module RelationScopes
        extend ::Trax::Model::Mixin

        mixed_in do |**options|
          options.each_pair do |scope_name, scope_options|
            define_model_relationship_scope(scope_name, scope_options)
          end
        end

        module ClassMethods
          def define_model_relationship_scope(scope_name, scope_options)
            scope_options[:model] = scope_options[:class_name]
            define_model_relationship_scope_for_field(scope_name, **scope_options)
          end

          private
          def define_model_relationship_scope_for_field(scope_name, scope:, model:, source_scope:, **rest)
            define_singleton_method(scope_name) do |*values|
              values.flat_compact_uniq!
              self.__send__(scope, model.constantize.__send__(source_scope, values))
            end
          end
        end
      end
    end
  end
end
