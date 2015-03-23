module Trax
  module Model
    class Railtie < ::Rails::Railtie
      ::ActiveSupport.on_load(:active_record) do

        def self.inherited(subklass)
          subklass.include(::Trax::Model) if ::Trax::Model.config.auto_include
          super(subklass)
        end
      end
    end
  end
end
