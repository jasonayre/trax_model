module Trax
  module Model
    module Mixins
      module CachedRelations
        extend ::Trax::Model::Mixin

        def cache_key_without_timestamp
          "#{self.class.name.underscore}/#{self.id}"
        end

        module ClassMethods
          def cached_belongs_to(_relation_name, **options)
            define_method("cached_#{_relation_name}") do
              cache_key_args = self.class.cache_key_for_belongs_to_relation(self, _relation_name, **options)

              ::Trax::Model.cache.fetch(*cache_key_args) do
                self.__send__(_relation_name)
              end
            end

            define_method("clear_cached_#{_relation_name}") do
              cache_key_args = self.class.cache_key_for_belongs_to_relation(self, _relation_name, **options)
              ::Trax::Model.cache.delete(*cache_key_args)
            end
          end

          def cache_key_for_belongs_to_relation(_record, _relation_name, primary_key: :id, scope:nil, **options)
            model_collection_name = self.reflect_on_association(_relation_name).plural_name
            singular_relation_name = model_collection_name.singularize
            options[:foreign_key] ||= "#{singular_relation_name}_id"
            options.merge!({scope => _record.__send__(scope)}) if scope
            foreign_record_id = _record.__send__(options[:foreign_key])

            cache_key_options = {}.tap do |h|
              h[scope] = _record.__send__(scope) if scope
              h[:namespace] = model_collection_name
            end

            cache_key_args = [foreign_record_id, cache_key_options]
          end
        end
      end
    end
  end
end
