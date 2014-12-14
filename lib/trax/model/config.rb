module Trax
  module Model
    class Config < ::Hashie::Dash
      ERROR_MESSAGES = {
        :invalid_uuid_prefix => [
          "UUID prefix must be 2 characters long",
          "and be 0-9 or a-f",
          "for hexadecimal id compatibility"
        ].join("\n")
      }.freeze

      property :uuid_prefix, :default => nil
      property :uuid_column, :default => :id

      def uuid_prefix=(prefix)
        if prefix.length != 2 || prefix.chars.any?{|char| char !~ /[0-9a-f]/ }
          raise ::Trax::Model::Errors::InvalidPrefixForUUID.new(prefix)
        end

        self[:uuid_prefix] = ::Trax::Model::UUIDPrefix.new(prefix)
      end
    end
  end
end
