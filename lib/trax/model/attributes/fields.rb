module Trax
  module Model
    module Attributes
      module Fields
        def self.extended(mod)
          mod.module_attribute(:_blank_fields_hash) {
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

        def values
          all.values
        end

        def [](name)
          const_get(name.to_s.camelize)
        end
      end
    end
  end
end
