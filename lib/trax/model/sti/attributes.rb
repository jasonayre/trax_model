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

          self.belongs_to(self._attribute_set_relation_name, :class_name => self._attribute_set_class_name)
        end

        def attribute_set
          build_attribute_set if super.nil?

          super
        end

        module ClassMethods
          def sti_attribute(*args)
            options = args.extract_options!

            args.each do |attribute_name|
              raise ::Trax::Model::Errors::STIAttributeNotFound unless self._attribute_set_class_name.constantize.column_names.include?("#{attribute_name}")

              self._sti_attributes << attribute_name

              self.delegate(attribute_name, :to => :attribute_set)
              self.delegate("#{attribute_name}=", :to => :attribute_set) unless options.key?(:writer) && options[:writer] == false
            end
          end
        end
      end
    end
  end
end
