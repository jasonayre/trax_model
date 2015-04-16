module Trax
  module Model
    class Railtie < ::Rails::Railtie
      initializer 'trax_model.active_record' do
        require_relative "../active_record_extensions"
      end

      ::ActiveSupport.on_load(:active_record) do
        binding.pry
        def self.inherited(subklass)
          subklass.include(::Trax::Model) if ::Trax::Model.config.auto_include
          super(subklass)


        end
      end
    end
  end
end
