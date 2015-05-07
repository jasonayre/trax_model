module Trax
  module Model
    class Config < ::Hashie::Dash
      property :uuid_prefix, :default => nil
      property :uuid_column, :default => :id

      def uuid_prefix=(prefix)
        if prefix.length != 2 || prefix.chars.any?{|char| char !~ /[0-9a-f]/ }
          raise ::Trax::Model::Errors::InvalidPrefixForUUID.new(:prefix => prefix)
        end

        self[:uuid_prefix] = ::Trax::Model::UUIDPrefix.new(prefix)
      end
    end
  end
end
