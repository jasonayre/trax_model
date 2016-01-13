module Trax
  module Model
    module Mixins
      module CachedFindBy
        extend ::Trax::Model::Mixin

        module ClassMethods
          def cached_find_by(**params)
            cache_key = ::Trax::Model::CacheKey.new(self.name.underscore.pluralize, '.find_by', **params)

            ::Trax::Model.cache.fetch(cache_key, cache_key.options) do
              self.find_by(cache_key.search_params)
            end
          end

          def cached_where(**params)
            cache_key = ::Trax::Model::CacheKey.new(self.name.underscore.pluralize, '.where', **params)

            ::Trax::Model.cache.fetch(cache_key, cache_key.options) do
              self.where(cache_key.search_params).to_a
            end
          end

          def clear_cached_find_by(**params)
            cache_key = ::Trax::Model::CacheKey.new(self.name.underscore.pluralize, '.find_by', **params)

            ::Trax::Model.cache.delete(cache_key)
          end

          def clear_cached_where(**params)
            cache_key = ::Trax::Model::CacheKey.new(self.name.underscore.pluralize, '.where', **params)

            ::Trax::Model.cache.delete(cache_key)
          end
        end
      end
    end
  end
end
