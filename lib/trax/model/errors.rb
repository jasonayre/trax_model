module Trax
  module Model
    module Errors
      class Base < StandardError
        def initialize(*args)
          message = (self.class::MESSAGE + args).join("\n")
          super(message)
        end
      end

      class InvalidPrefix < Trax::Model::Errors::Base
        MESSAGE = [
          "UUID prefix must be 2 characters long",
          "and be 0-9 or a-f",
          "for hexadecimal id compatibility"
        ]
      end

      class DuplicatePrefixRegistered < Trax::Model::Errors::Base
        MESSAGE = [
          "UUID prefix must be unique, the",
          "following prefix was already registered"
        ]
      end
    end
  end
end
