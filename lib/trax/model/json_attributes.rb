require 'ostruct'

module Trax
  module Model
    module JsonAttributes
      include ::Trax::Model::Mixin

      MODULE_NAME = :JsonAttributes

      included do
        class_attribute :json_attribute_fields

        self.json_attribute_fields = ::ActiveSupport::HashWithIndifferentAccess.new
      end

      # def read_attribute(attribute_name)
      #   if self.class.json_attribute_fields.key?(attribute_name)
      #     # binding.pry
      #     current_value = super
      #     return current_value if current_value.is_a?(self.json_attribute_fields[attribute_name])
      #     write_attribute(attribute_name, current_value)
      #
      #     # wrapped_value = self.json_attribute_fields[attribute_name].new(current_value, owner: self, attribute_name: attribute_name)
      #
      #     # self.__send__("#{attribute_name}=", current_value)
      #
      #     # self.send(:write_attribute_with_type_cast, attribute_name.to_s, wrapped_value, false)
      #
      #     super
      #   else
      #     super(attribute_name)
      #   end
      # end

      # def write_attribute(attribute_name, value)
      #   if self.class.json_attribute_fields.key?(attribute_name)
      #     wrapped_value = self.json_attribute_fields[attribute_name].new(value, owner: self, attribute_name: attribute_name)
      #     write_attribute_with_type_cast(attribute_name.to_s, wrapped_value, false)
      #   else
      #     super(attribute_name, value)
      #   end
      # end

      module ClassMethods
        def json_attribute(attribute_name, &block)
          #this ensures that super method overrides work correctly
          #http://thepugautomatic.com/2013/07/dsom/
          if const_defined?(MODULE_NAME, _search_ancestors = false)
            mod = const_get(MODULE_NAME)
          else
            mod = const_set(MODULE_NAME, Module.new)
            include mod
          end

          attributes_klass_name = "#{attribute_name}_attributes".classify
          attributes_klass = const_set(attributes_klass_name, ::Class.new(::Trax::Model::JsonAttribute))
          attributes_klass.instance_eval(&block)

          # attribute_type_klass_name = "#{attribute_name}_types".classify
          # binding.pry
          # attribute_type_klass = const_set(attribute_type_klass_name, ::Class.new(::Trax::Model::JsonAttributeType))

          # binding.pry

          attribute(attribute_name, ::Trax::Model::JsonAttributeType.new(target_klass: attributes_klass))

          mod.module_eval do
            # self.send(:define_method, :"#{attribute_name.to_s}") do
            #   ivar = :"@#{attribute_name}"
            #   return instance_variable_get(ivar) if instance_variable_names.include?("@#{attribute_name}") && instance_variable_get(ivar).is_a?(self.json_attribute_fields[attribute_name])
            #   wrapped_json = json_attribute_fields[attribute_name].new(super(), owner: self, attribute_name: attribute_name)
            #   instance_variable_set(ivar, wrapped_json)
            #   instance_variable_get(ivar)
            # end

            # define_method(:"#{attribute_name.to_s}") do
            #   ivar = :"@#{attribute_name}"
            #
            #   current_value = super()
            #   return current_value if current_value.is_a?(self.json_attribute_fields[attribute_name])
            #
            #   self.send(:write_attribute_with_type_cast, attribute_name.to_s, current_value, false)
            #   # super()
            #   binding.pry
            #   # self.send(:write_attribute_with_type_cast, :ui_settings, "blah", false)
            #
            #   # return instance_variable_get(ivar) if instance_variable_names.include?("@#{attribute_name}") && instance_variable_get(ivar).is_a?(self.json_attribute_fields[attribute_name])
            #   # wrapped_json = json_attribute_fields[attribute_name].new(self[attribute_name], owner: self, attribute_name: attribute_name)
            #   # # binding.pry
            #   # instance_variable_set(ivar, wrapped_json)
            #   # instance_variable_get(ivar)
            # end

            # define_method(:"#{attribute_name.to_s}=") do |val|
            #   ivar = :"@#{attribute_name}"
            #   wrapped_value = self.json_attribute_fields[attribute_name].new(val, owner: self, attribute_name: attribute_name)
            #   write_attribute_with_type_cast(attribute_name, wrapped_value, false)
            #
            #   new_value = super(wrapped_value)
            #   binding.pry
            #   new_value
            #   # instance_variable_set(ivar, read_attribute(attribute_name))
            #   # return self.__send__(attribute_name)
            # end
          end

          # self.send(:define_method, :"#{attribute_name.to_s}") do
          #   ivar = :"@#{attribute_name}"
          #   return instance_variable_get(ivar) if instance_variable_names.include?("@#{attribute_name}") && instance_variable_get(ivar).is_a?(self.json_attribute_fields[attribute_name])
          #   wrapped_json = json_attribute_fields[attribute_name].new(super(), owner: self, attribute_name: attribute_name)
          #   instance_variable_set(ivar, wrapped_json)
          #   instance_variable_get(ivar)
          # end


          # mod = Module.new
          # include mod



          # binding.pry
          #
          # self.send(:define_method, :"#{attribute_name.to_s}=") do |val|
          #   ivar = :"@#{attribute_name}"
          #   write_attribute(attribute_name, self.json_attribute_fields[attribute_name].new(val, owner: self, attribute_name: attribute_name))
          #   instance_variable_set(ivar, read_attribute(attribute_name))
          #   binding.pry
          #   return self.__send__(attribute_name)
          # end

          self.json_attribute_fields[attribute_name] = attributes_klass
          self.default_value_for(attribute_name) { {} }
          self.validates(attribute_name, :json_attribute => true)
        end
      end
    end
  end
end
