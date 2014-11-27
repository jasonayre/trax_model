module Trax
  module Model
    class Config < ::Hashie::Dash
      ERROR_MESSAGES = {
        :invalid_uuid_prefix => [
          "UUID prefix must be 2 characters long",
          "and can only include a-f0-9",
          "for hexadecimal id compatibility"
        ].join("\n")
      }.freeze

      property :uuid_prefix, :default => nil
      property :uuid_column, :default => :id

      def uuid_prefix=(prefix)
        if prefix.length != 2 || prefix !~ /[a-f0-9]{2}/
          raise ERROR_MESSAGES[:invalid_uuid_prefix]
        end

        self[:uuid_prefix] = prefix
      end
    end
  end
end
