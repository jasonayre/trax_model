module Trax
  module Model
    module Mixins
      module CachedRelations
        extend ::Trax::Model::Mixin

        include ::Trax::Model::Mixins::CachedFindBy

        module ClassMethods
          def cached_belongs_to(relation_name, **options)
            define_method("cached_#{relation_name}") do
              relation = self.class.reflect_on_association(relation_name)
              foreign_key = (relation.foreign_key || "#{relation.name}_id").to_sym
              params = { :id => self.__send__(foreign_key) }.merge(options)
              relation.klass.cached_find_by(**params)
            end

            define_method("clear_cached_#{relation_name}") do
              relation = self.class.reflect_on_association(relation_name)
              foreign_key = (relation.foreign_key || :"#{relation.name}_id").to_sym
              params = { :id => self.__send__(foreign_key) }.merge(options)
              relation.klass.clear_cached_find_by(**params)
            end
          end

          def cached_has_one(relation_name, **options)
            define_method("cached_#{relation_name}") do
              relation = self.class.reflect_on_association(relation_name)
              foreign_key = (relation.foreign_key || "#{relation.name}_id").to_sym
              params = { foreign_key => self.__send__(:id) }.merge(options)
              params.merge!(relation.klass.instance_eval(&relation.scope).where_values_hash.symbolize_keys) if relation.scope
              relation.klass.cached_find_by(**params)
            end

            define_method("clear_cached_#{relation_name}") do
              relation = self.class.reflect_on_association(relation_name)
              foreign_key = (relation.foreign_key || :"#{relation.name}_id").to_sym
              params = { foreign_key => self.__send__(:id) }.merge(options)
              params.merge!(relation.klass.instance_eval(&relation.scope).where_values_hash.symbolize_keys) if relation.scope
              relation.klass.clear_cached_find_by(**params)
            end
          end

          def cached_has_many(relation_name, **options)
            define_method("cached_#{relation_name}") do
              relation = self.class.reflect_on_association(relation_name)
              foreign_key = :"#{relation.foreign_key}"
              params = {foreign_key => self.__send__(:id)}.merge(options)
              relation.klass.cached_where(**params)
            end

            define_method("clear_cached_#{relation_name}") do
              relation = self.class.reflect_on_association(relation_name)
              foreign_key = :"#{relation.foreign_key}"
              params = {foreign_key => self.__send__(:id)}.merge(options)
              relation.klass.clear_cached_where(**params)
            end
          end
        end
      end
    end
  end
end
