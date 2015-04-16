ActiveRecord::ConnectionAdapters::PostgreSQL::OID::Json.class_eval do
  def include_trax_json_attribute(klass)
    # singleton_class = class << self; include Typecaster end;
    # singleton_class.set_json_attribute_klass(klass)

    self.singleton_class.instance_eval do
      self.instance_variable_set("@json_attribute_class", klass)
      # send(:include, ::Typecaster)
    end

    self
    # self.set_json_attribute_klass(klass)
    # singleton_class.instance_variable_set("@json_attribute_class", klass)
    # self
  end

  def self.include_trax_json_attribute(klass)
    define_method name do
      "value of #{name}"
    end
  end


end

module Typecaster
  def set_json_attribute_klass(klass)
    # self.attr_reader(:json_attribute_class)
    # singleton_class.instance_variable_set("@json_attribute_class", klass)
    # instance_variable_set("@json_attribute_class", klass)
  end

  # def type_cast_from_database(*args)
  #   val = super(*args)
  #   json_attribute_klass.new(val)
  # end
  def json_attribute_class

  end

  def type_cast_for_database(*args)
    val = super(*args)
    # binding.pry
  end

  def type_cast_from_database(*args)
    val = super(*args)

    if val
      singleton_class.instance_variable_get(:@json_attribute_class).new(val)
    else
      singleton_class.instance_variable_get(:@json_attribute_class).new
    end
  end
end
# module ActiveRecord
#   module ConnectionAdapters
#     module PostgreSQL
#       module OID # :nodoc:
#         class Jsonb
#
#           def type
#             :jsonb
#           end
#
#           # def changed_in_place?(raw_old_value, new_value)
#           #   # Postgres does not preserve insignificant whitespaces when
#           #   # roundtripping jsonb columns. This causes some false positives for
#           #   # the comparison here. Therefore, we need to parse and re-dump the
#           #   # raw value here to ensure the insignificant whitespaces are
#           #   # consistent with our encoder's output.
#           #   raw_old_value = type_cast_for_database(type_cast_from_database(raw_old_value))
#           #   super(raw_old_value, new_value)
#           # end
#
#
#
#         end
#       end
#     end
#   end
# end
