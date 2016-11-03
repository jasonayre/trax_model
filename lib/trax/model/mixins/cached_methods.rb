module Trax
  module Model
    module Mixins
      module CachedMethods
        extend ::Trax::Model::Mixin

        module ClassMethods
          def cached_class_method(method_name, **config_options)
            define_singleton_method("cached_#{method_name}") do |*args, **options|
              method_cache_key = ::Trax::Model::CacheKey.for_class_method(self, method_name, *args, **config_options.merge(options))
              accepts_args = method(method_name).arity != 0
              has_options = !options.empty?

              ::Trax::Model.cache.fetch(method_cache_key) do
                result = if !accepts_args && !has_options
                  __send__(method_name)
                elsif accepts_args && has_options
                  __send__(method_name, *args, **options)
                elsif accepts_args
                  __send__(method_name, *args)
                elsif has_options
                  __send__(method_name, **options)
                end

                result
              end
            end
          end

          def cached_instance_method(method_name, **config_options)
            define_method("cached_#{method_name}") do |*args, **options|
              method_cache_key = ::Trax::Model::CacheKey.for_instance_method(self.class, method_name, *args, **config_options.merge(options))
              accepts_args = method(method_name).arity != 0
              has_options = method(method_name).parameters.any?

              ::Trax::Model.cache.fetch(method_cache_key) do
                result = if !accepts_args && !has_options
                  __send__(method_name)
                elsif accepts_args && has_options
                  __send__(method_name, *args, **options)
                elsif accepts_args
                  __send__(method_name, *args)
                elsif has_options
                  __send__(method_name, **options)
                end

                result
              end
            end
          end
        end
      end
    end
  end
end
