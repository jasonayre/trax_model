module Trax
  module Model
    class CacheKey < SimpleDelegator
      CACHE_OPTION_KEYS = [ :expires_in ].freeze

      attr_reader :options, :search_params

      def self.for_class_method(klass, method_name, *args, **options)
        new("#{klass.name.underscore}.#{method_name}", *args, **options)
      end

      def self.for_instance_method(klass, method_name, *args, **options)
        new("#{klass.name.underscore}##{method_name}", *args, **options)
      end

      def initialize(path_for_method, *args, **params)
        @path_for_method = path_for_method
        @arguments = args
        params.symbolize_keys!
        @options = params.extract!(*CACHE_OPTION_KEYS)
        @search_params = params
        @obj = ::Set[@path_for_method, *args.map(&:to_s).sort, params.sort].to_a.flatten
      end

      def __getobj__
        @obj
      end

      def to_s
        @obj.join('/')
      end
    end
  end
end
