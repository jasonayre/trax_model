module Trax
  module Model
    module MTI
      module Entity
        extend ::ActiveSupport::Concern

        included do
          class_attribute :_mti_namespace

          scope :records, lambda{
            map(&:entity)
          }

          scope :fully_loaded, lambda{
            relation = current_scope.dup
            entity_ids = relation.pluck(:id)
            entity_types = entity_ids.map { |id| ::Trax::Model::UUID.new(id[0..1]) }
                                     .map(&:record_type)
                                     .flatten
                                     .compact
                                     .uniq

            relation_names = entity_types.map{ |type| :"#{type.name.demodulize.underscore}_entity" }

            current_scope.includes(relation_names).references(relation_names)
          }
        end

        def model_type
          @model_type ||= uuid.record_type
        end

        def model_type_key
          :"#{model_type.name.demodulize.underscore}_entity"
        end

        def model
          @model ||= __send__(model_type_key)
        end

        def uuid
          @uuid ||= self[:id].uuid
        end

        module ClassMethods
          def mti_namespace(namespace)
            _mti_namespace = (namespace.is_a?(String)) ? namespace.constantize : namespace

            _mti_namespace.all.reject{|model| model.abstract_class }.each do |subclass|
              key = :"#{subclass.name.demodulize.underscore}_entity"
              has_one key, :class_name => subclass.name, :foreign_key => :id
            end
          end

          def multiple_table_inheritance_namespace(namespace)
            mti_namespace(namespace)
          end
        end
      end
    end
  end
end
