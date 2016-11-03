module Trax
  module Model
    module CacheStoreExtensions
      def fetch(*args, **options)
        if(args.first.is_a?(::Trax::Model::CacheKey))
          cache_key = args.first
          super(cache_key, **cache_key.options)
        else
          cache_key = ::Trax::Model::CacheKey.new(*args, **options)
          super(cache_key, **cache_key.options)
        end
      end
    end
  end
end
