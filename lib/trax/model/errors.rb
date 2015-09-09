require 'trax/core/errors'

module Trax
  module Model
    module Errors
      class InvalidOption < ::Trax::Core::Errors::Base
        argument :option
        argument :valid_options

        message {
          "Invalid option #{option}: must instead be one of #{valid_options.join(", ")}"
        }
      end

      class MixinNotRegistered < ::Trax::Core::Errors::Base
        argument :mixin
        argument :model

        message {
          "#{model} tried to load mixin: #{mixin}, whichdoes not exist in " \
          "registry. Registered mixins were #{::Trax::Model.mixin_registry.keys.join(', ')} \n"
        }
      end

      class InvalidPrefix < ::Trax::Core::Errors::Base
        argument :prefix, :required => true

        message {
          "Prefix #{prefix}"
          "UUID prefix must be 2 characters long" \
          "and be 0-9 or a-f" \
          "for hexadecimal id compatibility"
        }
      end

      class DuplicatePrefixRegistered < Trax::Core::Errors::Base
        argument :prefix, :required => true
        argument :model, :required => true

        message {
          "UUID prefix must be unique,\n" \
          "#{prefix} was already registered by #{model}!"
        }
      end

      class FieldDoesNotExist < Trax::Core::Errors::Base
        argument :field, :required => true
        argument :model, :required => true

        message { "Field #{field} does not exist for #{model}" }
      end

      class STIAttributeNotFound < ::Trax::Core::Errors::Base
        argument :attribute_name

        message { "STI Attribute was not found for #{attribute_name}" }
      end
    end
  end
end
