module Trax
  module Model
    module Attributes
      module Fields
        def self.extended(base)
          base.module_attribute(:_blank_fields_hash) {
            ::Hashie::Mash.new
          }
        end

        def all
          @all ||= begin
            constants.map{|const_name| const_get(const_name) }.each_with_object(self._blank_fields_hash) do |klass, result|
              result[klass.name.symbolize] = klass
            end
          end
        end

        def by_type(*type_names)
          all.select{|k,v| type_names.include?(v.type) }
             .try(:with_indifferent_access)
        end

        def each(&block)
          all.values(&block)
        end

        def each_pair(*args, &block)
          all.each_pair(*args, &block)
        end

        def booleans
          @booleans ||= by_type(:boolean)
        end

        def enums
          @enums ||= by_type(:enum)
        end

        def structs
          @structs ||= by_type(:struct)
        end

        def strings
          @strings ||= by_type(:string)
        end

        def to_schema
          schema = all.inject(::Hashie::Mash.new) do |result, (k,v)|
            case v.try(:type)
            when :enum
              result[k] = v.to_schema
            when :struct
              result[k] = v.to_schema
            else
              result[k] = v.try(:to_schema)
            end

            result
          end
          schema
        end

        def values
          all.values
        end

        def [](_name)
          const_get(_name.to_s.camelize)
        end
      end
    end
  end
end
