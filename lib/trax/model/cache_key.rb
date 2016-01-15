module Trax
  module Model
    class CacheKey < SimpleDelegator
      CACHE_OPTION_KEYS = [ :expires_in ].freeze

      attr_reader :options, :search_params

      def initialize(*args, **params)
        params.symbolize_keys!
        @options = params.extract!(*CACHE_OPTION_KEYS)
        @search_params = params
        @obj = ::Set[*args.sort, params.sort].flatten.to_a
      end

      def __getobj__
        @obj
      end
    end
  end
end
