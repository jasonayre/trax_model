module Trax
  module Model
    module Mixins
      module StiEnum
        extend ::Trax::Model::Mixin

        mixed_in do |**options|
          default_options = { :type_column => :type, :enum_column => :kind }

          options = default_options.merge!(options)
        end

        included do
          after_initialize :set_kind_from_type
          after_initialize :set_type_from_kind
        end

        def set_type_from_kind
          self[:type] = self.class.kind_to_type_mapping[self[:kind]] if self.has_attribute?(:kind) && self.has_attribute?(:type) && !self[:type]
        end

        def set_kind_from_type
          self[:kind] = self.class.type_to_kind_mapping[self[:type]] if self.has_attribute?(:kind) && self.has_attribute?(:type) && self.has_attribute?(:type) && !self[:kind]
        end

        module ClassMethods
          def subclass_from_attributes?(attrs)
            _attrs = attrs.with_indifferent_access if attrs
            attrs[:type] = kind_to_type_mapping[_attrs["kind"]] if attrs && !_attrs.key?("type") && _attrs.key?("kind")
            super(attrs)
          end

          def type_to_kind_mapping
            @type_to_kind_mapping ||= fields[:kind].choices.each_with_object({}) do |choice, result|
              result[choice.attributes[:type]] = choice.to_s
              result
            end.with_indifferent_access
          end

          def kind_to_type_mapping
            @kind_to_type_mapping ||= fields[:kind].choices.each_with_object({}) do |choice, result|
              result[choice.to_s] = choice.attributes[:type]
              result
            end.with_indifferent_access
          end
        end
      end
    end
  end
end
