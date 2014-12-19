# An opinionated enum preconfiguration:
# Uses simple_enum instead of active record built in enum, due to the complete
# and utter polution it causes to your classes. in addition, AR does not prefix
# enums with anything, i.e.
# class User
# enum :gender => [:unknown, :male, :female]
# enum :locale => [:unknown, :en, :ca]
# will break because :unknown cant be used twice, since it defines an User.unknown
# method, the value which does not even make sense in alot of situations, out of context
#
# So, we use simple_enum instead, which will allow us to do that
# in addition, I dont like that simple_enum does not allow you to raise errrors at the activerecord
# level using validations, therefore you cant reuse the same interface for displaying errors
# to the user if an invalid value is picked
# so validation is added when an enum is defined
# also defines just 2 generic scopes, by_enum_name, and by_enum_name_not, which accept multiple args
# i.e. by_gender(:male), by_gender_not(:female, :unknown)
# in interest of not polluting the class with scopes for each individual enum value

module Trax
  module Model
    module Enum
      extend ::ActiveSupport::Concern

      module ClassMethods
        def define_scopes_for_trax_enum(enum_name)
          scope_method_name = :"by_#{enum_name}"
          scope_not_method_name = :"by_#{enum_name}_not"

          self.scope scope_method_name, lambda { |*values|
            enum_hash = self.__send__("#{enum_name}".pluralize).hash
            where(enum_name => enum_hash.with_indifferent_access.slice(*values.flatten.compact.uniq).values)
          }
          self.scope scope_not_method_name, lambda { |*values|
            enum_hash = self.__send__("#{enum_name}".pluralize).hash
            where.not(enum_name => enum_hash.with_indifferent_access.slice(*values.flatten.compact.uniq).values)
          }
        end

        def as_enum(enum_name, enum_mapping, options = {})
          # enum_mapping = options.extract!(enum_name)[enum_name]
          enum_values = enum_mapping.is_a?(Hash) ? enum_mapping.keys : enum_mapping
          options.assert_valid_keys(:prefix, :source, :message, :default)

          options[:message] ||= "Invalid value selected for #{enum_name}"
          options[:prefix] ||= true
          options[:source] ||= enum_name
          default_value = options.extract!(:default)[:default] if options.key?(:default)

          validation_options = { :in => enum_values, :message => options.extract!(:message)[:message] }

          self.validates_inclusion_of(enum_name, validation_options)
          define_scopes_for_trax_enum(enum_name)

          self.default_value_for(enum_name) { default_value } if default_value

          super(enum_name, enum_mapping, options)
        end
      end
    end
  end
end
