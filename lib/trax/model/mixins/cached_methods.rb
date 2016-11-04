module Trax
  module Model
    module Mixins
      module CachedMethods
        extend ::Trax::Model::Mixin

        module ClassMethods
          def cached_class_method(method_name, as:nil, **config_options)
            cached_method_name = as || "cached_#{method_name}"
            cache_clearer_method_name = "clear_#{cached_method_name}"

            define_singleton_method(cached_method_name) do |*args, **options|
              method_cache_key = ::Trax::Model::CacheKey.for_class_method(self, method_name, *args, **config_options.merge(options))

              ::Trax::Model.cache.fetch(method_cache_key) do
                __smartsend__(method_name, *args, **options)
              end
            end

            define_singleton_method(cache_clearer_method_name) do |*args, **options|
              method_cache_key = ::Trax::Model::CacheKey.for_class_method(self, method_name, *args, **config_options.merge(options))

              ::Trax::Model.cache.delete(method_cache_key)
            end
          end

          def cached_instance_method(method_name, as:nil, **config_options)
            cached_method_name = as || "cached_#{method_name}"
            cache_clearer_method_name = "clear_#{cached_method_name}"

            define_method(cached_method_name) do |*args, **options|
              method_cache_key = ::Trax::Model::CacheKey.for_instance_method(self.class, method_name, self.id, *args, **config_options.merge(options))

              ::Trax::Model.cache.fetch(method_cache_key) do
                __smartsend__(method_name, *args, **options)
              end
            end

            define_method(cache_clearer_method_name) do |*args, **options|
              method_cache_key = ::Trax::Model::CacheKey.for_instance_method(self.class, method_name, self.id, *args, **config_options.merge(options))

              ::Trax::Model.cache.delete(method_cache_key)
            end
          end
        end
      end
    end
  end
end
