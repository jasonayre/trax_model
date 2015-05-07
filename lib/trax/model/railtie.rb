module Trax
  module Model
    class Railtie < ::Rails::Railtie
      ::ActiveSupport.on_load(:active_record) do
        def self.inherited(subklass)
          subklass.include(::Trax::Model) if ::Trax::Model.config.auto_include

          super(subklass)

          ::Trax::Model.config.auto_include_mixins.each do |mixin|
            subklass.mixin(mixin)
          end if ::Trax::Model.config.auto_include_mixins.any?
        end
      end
    end
  end
end
