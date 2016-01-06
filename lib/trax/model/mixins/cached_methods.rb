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
          "#{self._cached_methods_namespace}/#{self.__send__(self.class._cached_methods_key)}/#{_name}"
        end

        module ClassMethods
          def cached_methods_namespace(_namespace)
            self._cached_methods_namespace = _namespace
          end

          def _cached_methods_class_namespace
            "#{_cached_methods_namespace}/class"
          end

          def cache_key_for_class_method(_name)
            "#{self._cached_methods_namespace}/class/#{_name}"
          end

          def clear_cache_for_class_method(_name)
            method_cache_key = cache_key_for_class_method(_name)
            ::Trax::Model.cache.clear(method_cache_key)
          end

          def cached_method(_name, **options)
            define_method("cached_#{_name}") do
              ::Trax::Model.cache.fetch(cache_key_for_method(_name), options) do
                self.__send__(_name)
              end
            end

            define_method("clear_cached_#{_name}") do
              ::Trax::Model.cache.delete(cache_key_for_method(_name))
            end
          end

          def cached_class_method(_name, **options)
            method_cache_key = cache_key_for_class_method(_name)

            define_singleton_method("cached_#{_name}") do
              ::Trax::Model.cache.fetch(method_cache_key, options) do
                self.__send__(_name)
              end
            end

            define_singleton_method("clear_cached_#{_name}") do
              ::Trax::Model.cache.delete(method_cache_key)
            end
          end
        end
      end
    end
  end
end
