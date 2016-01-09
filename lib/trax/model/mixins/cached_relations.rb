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
            define_method("cache_key_arguments_for_#{_relation_name}") do
              self.class.cache_key_for_belongs_to_relation(self, _relation_name, **options)
            end

            define_method("cached_#{_relation_name}") do
              cache_key_args = __send__("cache_key_arguments_for_#{_relation_name}")

              puts cache_key_args.inspect

              ::Trax::Model.cache.fetch(*cache_key_args) do
                self.__send__(_relation_name)
              end
            end

            define_method("clear_cached_#{_relation_name}") do
              cache_key_args = __send__("cache_key_arguments_for_#{_relation_name}")
              ::Trax::Model.cache.delete(*cache_key_args)
            end
          end

          def cache_key_for_belongs_to_relation(_record, _relation_name, primary_key: :id, scope:nil, **options)
            model_collection_name = self.reflect_on_association(_relation_name).plural_name
            singular_relation_name = model_collection_name.singularize
            options[:foreign_key] ||= "#{singular_relation_name}_id"
            foreign_record_id = _record.__send__(options[:foreign_key])

            cache_key_options = {}.tap do |h|
              if scope && scope == :self
                h["#{_record.class.name.demodulize.underscore}_id".to_sym] = _record.id
              elsif scope
                h[scope] = _record.__send__(scope)
              end
            end

            cache_key_options.merge!(options.extract!(:expires_in))
            cache_key_args = ["#{_record.id}/#{singular_relation_name}", cache_key_options]
          end

          def cached_has_one(_relation_name, **options)
            define_method("cache_key_arguments_for_#{_relation_name}") do
              self.class.cache_key_for_has_one_relation(self, _relation_name, **options)
            end

            define_method("cached_#{_relation_name}") do
              cache_key_args = __send__("cache_key_arguments_for_#{_relation_name}")

              ::Trax::Model.cache.fetch(*cache_key_args) do
                self.__send__(_relation_name)
              end
            end

            define_method("clear_cached_#{_relation_name}") do
              cache_key_args = __send__("cache_key_arguments_for_#{_relation_name}")
              ::Trax::Model.cache.delete(*cache_key_args)
            end
          end

          def cache_key_for_has_one_relation(_record, _relation_name, primary_key: :id, scope:nil, **options)
            model_collection_name = self.reflect_on_association(_relation_name).plural_name
            singular_relation_name = model_collection_name.singularize

            cache_key_options = {}.tap do |h|
              if scope && scope == :self
                h["#{_record.class.name.demodulize.underscore.to_sym}_id".to_sym] = _record.id
              elsif scope
                h[scope] = _record.__send__(scope)
              end
            end

            cache_key_options.merge!(options.extract!(:expires_in))
            cache_key_string = "#{_record.id}/#{_relation_name}"
            cache_key_args = [cache_key_string, cache_key_options]
          end

          def cached_has_many(_relation_name, **options)
            define_method("cache_key_arguments_for_#{_relation_name}") do
              self.class.cache_key_for_has_many_relation(self, _relation_name, **options)
            end

            define_method("cached_#{_relation_name}") do
              cache_key_args = __send__("cache_key_arguments_for_#{_relation_name}")

              ::Trax::Model.cache.fetch(*cache_key_args) do
                self.__send__(_relation_name)
              end
            end

            define_method("clear_cached_#{_relation_name}") do
              cache_key_args = __send__("cache_key_arguments_for_#{_relation_name}")
              ::Trax::Model.cache.delete(*cache_key_args)
            end
          end

          def cache_key_for_has_many_relation(_record, _relation_name, primary_key: :id, scope:nil, **options)
            model_collection_name = self.reflect_on_association(_relation_name).plural_name
            singular_relation_name = model_collection_name.singularize

            cache_key_options = {}.tap do |h|
              if scope && scope == :self
                h["#{_record.class.name.demodulize.underscore.to_sym}".to_sym] = _record.id
              elsif scope
                h[scope] = _record.__send__(scope)
              end
            end

            cache_key_options.merge!(options.extract!(:expires_in))
            cache_key_string = "#{_record.id}/#{_relation_name}"

            cache_key_args = [cache_key_string, cache_key_options]
            puts cache_key_args.inspect
            cache_key_args
          end
        end
      end
    end
  end
end
