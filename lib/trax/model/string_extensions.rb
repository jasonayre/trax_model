module Trax
  module Model
    module StringExtensions
      extend ::ActiveSupport::Concern

      def uuid
        ::Trax::Model::UUID === self ? ::Trax::Model::UUID.new(self) : nil
      end
    end
  end
end
