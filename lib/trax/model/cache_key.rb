module Trax
  module Model
    class CacheKey < SimpleDelegator
      CACHE_OPTION_KEYS = [ :expires_in ].freeze

      attr_reader :options, :search_params

      def initialize(*args, **params)
        params.symbolize_keys!
        @options = params.extract!(*CACHE_OPTION_KEYS)
        @search_params = params
        @obj = ::Set[*args.sort, params.sort].to_a.flatten
      end

      def __getobj__
        @obj
      end

      def to_s
        @obj.join("/")
      end
    end
  end
end
