module Trax
  module Model
    module STI
      module Attributes
        extend ::ActiveSupport::Concern

        #not configurable atm as you can see below

        included do
          class_attribute :_attribute_set_column,
                          :_attribute_set_class_name,
                          :_attribute_set_relation_name,
                          :_sti_attributes

          self._sti_attributes = []

          self._attribute_set_relation_name = :attribute_set
          self._attribute_set_column = :attribute_set_id
          self._attribute_set_class_name = "#{name}AttributeSet"

          self.belongs_to(self._attribute_set_relation_name, :class_name => self._attribute_set_class_name, :validate => true)
          self.validates(self._attribute_set_relation_name, :presence => true)

          self.before_create(:attribute_set)
        end

        def attributes
          super.merge!(sti_attributes)
        end

        def attribute_set
          build_attribute_set if super.nil?

          super
        end

        def sti_attributes
          sti_attribute_hash = self.class._sti_attributes.inject({}) do |result, attribute|
            result["#{attribute}"] = __send__(attribute)
            result
          end

          sti_attribute_hash
        end

        def super!(*args)
          method_caller = caller_locations(1,1)[0].label
          attribute_set.send(method_caller, *args)
        end

        module ClassMethods
          def sti_attribute(*args)
            options = args.extract_options!

            args.each do |attribute_name|
              return unless self._attribute_set_class_name.constantize.table_exists?
              raise ::Trax::Model::Errors::STIAttributeNotFound unless self._attribute_set_class_name.constantize.column_names.include?("#{attribute_name}")

              self._sti_attributes << attribute_name

              self.delegate(attribute_name, :to => :attribute_set)
              self.delegate("#{attribute_name}=", :to => :attribute_set) unless options.key?(:writer) && options[:writer] == false
            end
          end

          def validates_uniqueness_of!(*args)
            options = args.extract_options!

            args.each do |arg|
              validation_method_name = :"validate_#{arg.to_s}"

              self.send(:define_method, :"validate_#{arg.to_s}") do |*_args|
                where_scope_hash = {}
                field_value = self.__send__(arg)
                where_scope_hash[arg] = field_value

                where_scope = self._attribute_set_class_name.constantize.where(where_scope_hash).all

                options[:scope].each do |field|
                  scoped_field_value = self.__send__(field)
                  where_scope.merge(self.class.where({field => scoped_field_value}))
                end if options.has_key?(:scope)

                errors.add(arg, "has already been taken") if where_scope.limit(1).any?
              end

              self.validate(validation_method_name)
            end
          end
        end
      end
    end
  end
end
