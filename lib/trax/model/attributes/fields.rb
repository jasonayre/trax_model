module Trax
  module Model
    module Attributes
      module Fields
        def self.extended(mod)
          mod.module_attribute(:fields) {
            ::Hashie::Mash.new
          }
        end

        def all
          @all ||= begin
            constants.map{|const_name| const_get(const_name) }.each_with_object(self.fields) do |klass, result|
              result[klass.symbolic_name] = klass
            end
          end
        end

        def each(&block)
          all.values(&block)
        end

        def each_pair(*args, &block)
          all.each_pair(*args, &block)
        end

        # def fields
        #   all
        # end

        def values
          all.values
        end

        def [](name)
          const_get(name.to_s.camelize)
        end

        # def register(name, klass)
        #   const_set(name.to_s.camelize, klass)
        #   fields[name] = const_get(name.to_s.camelize)
        #   fields[name]
        # end
      end
    end
  end
end
