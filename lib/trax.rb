require 'trax/core'
require 'trax/model'

module Trax
  module NamedModule
    def self.new(subklass, **options, &block)
      _name = options.extract!(:name)[:name] if options.key?(:name)

      if _name
        ::Object.set_fully_qualified_constant(_name, ::Module.new do
          define_singleton_method(:name) do
            _name
          end

          instance_eval(&block) if block_given?
        end
        )

        Object.const_get(_name).extend(subklass) if subklass
        Object.const_get(_name)
      else
      end
    end
  end

  class ClassWithAttributes
    def self.new(subklass, **options, &block)
      _name = options.extract!(:name)[:name] if options.key?(:name)

      if _name
        klass = ::Object.set_fully_qualified_constant(_name, ::Class.new(subklass) do
          define_singleton_method(:name) do
            _name
          end

          options.each_pair do |k,v|
            self.class.class_attribute k
            self.__send__("#{k}=", v)
          end
        end
        )

        klass.instance_eval(&block) if block_given?
      else
        ::Class.new(subklass) do
          options.each_pair do |k,v|
            self.class.class_attribute k
            self.__send__("#{k}=", v)
          end

          instance_eval(&block) if block_given?
        end
      end

      Object.const_get(_name)
    end
  end
end
