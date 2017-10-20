module Trax
  module Model
    class Railtie < ::Rails::Railtie
      ::ActiveSupport.on_load(:active_record) do
        def self.inherited(subklass)
          if ::Trax::Model.config.auto_include
            subklass.include(::Trax::Model)
            subklass.include(::Trax::Model::Attributes::Dsl)
          end

          super(subklass)
          subklass.const_get(:ActiveRecord_Relation).include(::Trax::Model::RelationMethods)

          ::Trax::Model.config.auto_include_mixins.each do |mixin|
            subklass.mixin(mixin)
          end if ::Trax::Model.config.auto_include_mixins.any?
        end
      end
    end
  end
end
