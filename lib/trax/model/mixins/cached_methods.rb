module Trax
  module Model
    module Mixins
      module CachedMethods
        extend ::Trax::Model::Mixin

        mixed_in do |**options|
          default_options = { :cache_key => :id, :namespace => self.name.underscore, :store => ::Trax::Model.cache }
          options = default_options.merge!(options)
          self._cached_methods_key = options[:cache_key]
          self._cached_methods_namespace = options[:namespace]
          self._cached_methods_store = options[:store]
        end

        included do
          class_attribute :_cached_methods_key
          class_attribute :_cached_methods_namespace
          class_attribute :_cached_methods_store
        end

        def cache_key_for_method(_name)
          "#{self.__send__(self.class._cached_methods_key)}/instance/#{_name}"
        end

        module ClassMethods
          def cached_methods_namespace(_namespace)
            self._cached_methods_namespace = _namespace
          end

          def _cached_methods_class_namespace
            "#{self._cached_methods_namespace}/class"
          end

          def cache_key_for_class_method(_name)
            _name
          end

          def cache_key_for_record(_id)
            "#{self._cached_methods_namespace}/#{_id}/record"
          end

          def clear_cache_for_class_method(_name)
            method_cache_key = cache_key_for_class_method(_name)
            ::Trax::Model.cache.clear(method_cache_key, _cached_methods_class_namespace)
          end

          def cached_record(id, **options)
            cache_namespace_options = { :namespace => self._cached_methods_namespace }

            ::Trax::Model.cache.fetch(cache_key_for_record(_id), cache_namespace_options.dup.merge(options)) do
              self.__send__(_name)
            end
          end

          def cached_method(_name, **options)
            cache_namespace_options = { :namespace => self._cached_methods_namespace }

            define_method("cached_#{_name}") do
              ::Trax::Model.cache.fetch(cache_key_for_method(_name), cache_namespace_options.dup.merge(options)) do
                self.__send__(_name)
              end
            end

            define_method("clear_cached_#{_name}") do
              ::Trax::Model.cache.delete(cache_key_for_method(_name), cache_namespace_options)
            end
          end

          def cached_class_method(_name, **options)
            cache_namespace_options = { :namespace => self._cached_methods_class_namespace }
            method_cache_key = cache_key_for_class_method(_name)

            define_singleton_method("cached_#{_name}") do
              ::Trax::Model.cache.fetch(method_cache_key, cache_namespace_options.dup.merge(options)) do
                self.__send__(_name)
              end
            end

            define_singleton_method("clear_cached_#{_name}") do
              ::Trax::Model.cache.delete(method_cache_key, cache_namespace_options)
            end
          end
        end
      end
    end
  end
end
