module Trax
  module Model
    class UUIDPrefix < String
      HEX_LETTER_RANGE = ('a'..'f').to_a.freeze

      def self.all
        prefixes = (0..9).map do |digit|
          values = HEX_LETTER_RANGE.map do |character|
            prefix = [digit, character].join
            prefix
          end

          values
        end

        prefixes.flatten!.sort!
      end

      def self.build_from_integer(value)
        value_str = "#{value}"
        return new([value_str.chars.first.to_i, HEX_LETTER_RANGE[value_str.chars.last.to_i]].join)
      end

      def <=>(comparison_prefix)
        self.to_i <=> comparison_prefix.to_i
      end

      def index
        self.class.all.index(self)
      end

      def next
        self.class.all.at(index + 1)
      end

      def previous
        self.class.all.at(index - 1)
      end

      def to_digits
        return self.chars.map do |character|
          (character.downcase =~ /[a-f]/ ? HEX_LETTER_RANGE.index(character.downcase) : character)
        end
      end

      def to_i
        return self.to_digits.join.to_i
      end
    end
  end
end
