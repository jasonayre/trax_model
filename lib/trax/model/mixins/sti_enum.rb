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

        def kind=(val)
          result = super(val)
          set_type_from_kind! if set_type_from_kind?
          result
        end

        def type_for_kind
          self.class.kind_to_type_mapping[self[:kind].to_sym]
        end

        def kind_for_type
          self.class.type_to_kind_mapping[self[:type]]
        end

        def set_type_from_kind?
          self.has_attribute?(:kind) && self.has_attribute?(:type) && self[:type] != type_for_kind
        end

        def set_kind_from_type?
          self.has_attribute?(:kind) && self.has_attribute?(:type) && self[:kind] != kind_for_type
        end

        def set_type_from_kind
          self[:type] = type_for_kind if set_type_from_kind?
        end

        def set_kind_from_type
          self[:kind] = kind_for_type if set_kind_from_type?
        end

        def set_type_from_kind!
          self[:type] = type_for_kind
        end

        def set_kind_from_type!
          self[:kind] = kind_for_type
        end

        def type=(val)
          result = super(val)
          set_kind_from_type! if set_kind_from_type?
          result
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
