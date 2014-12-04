module Trax
  module Model
    class Config < ::Hashie::Dash
      ERROR_MESSAGES = {
        :invalid_uuid_prefix => [
          "UUID prefix must be 2 characters long",
          "First Character must be an integer 0-9",
          "Second character must be a letter a-f",
          "for hexadecimal id compatibility"
        ].join("\n")
      }.freeze

      property :uuid_prefix, :default => nil
      property :uuid_column, :default => :id

      def uuid_prefix=(prefix)
        if prefix.length != 2 || prefix.chars.first !~ /[0-9]/ || prefix.chars.last !~ /[a-f]/
          raise ERROR_MESSAGES[:invalid_uuid_prefix]
        end

        self[:uuid_prefix] = ::Trax::Model::UUIDPrefix.new(prefix)
      end
    end
  end
end
