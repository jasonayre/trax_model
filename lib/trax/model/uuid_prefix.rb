module Trax
  module Model
    class UUIDPrefix < String
      HEX_LETTER_RANGE = ('a'..'f').to_a.freeze
      HEX_DIGIT_RANGE = (0..9).to_a.freeze
      #9f = 96 so we need to begin at 96 when mapping back down [str,int]
      DIVIDING_VALUE = 96

      def self.all
        @all ||= begin
          lower_value_prefixes = HEX_DIGIT_RANGE.map do |digit|
            values = HEX_LETTER_RANGE.map do |character|
              prefix = [digit, character].join
              new(prefix)
            end

            values
          end

          higher_value_prefixes = HEX_LETTER_RANGE.map do |digit|
            values = HEX_DIGIT_RANGE.map do |character|
              prefix = [digit, character].join
              new(prefix)
            end

            values
          end

          [lower_value_prefixes, higher_value_prefixes].flatten!.sort!
        end
      end

      def self.build_from_integer(value)
        value_str = "#{value}"
        return new([value_str.chars.first.to_i, HEX_LETTER_RANGE[value_str.chars.last.to_i]].join)
      end

      def <=>(comparison_prefix)
        self.to_i <=> comparison_prefix.to_i
      end

      def in_higher_partition?
        "#{self}"[0] =~ /[a-f]/
      end

      def in_lower_partition?
        !in_higher_partition?
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
        digits = self.chars.map do |character|
          (character.downcase =~ /[a-f]/ ? HEX_LETTER_RANGE.index(character.downcase) : character)
        end

        #kind of wonky but multiply by 2 will ensure the letter prefixes begin with a higher value
        in_higher_partition? ? "#{((digits.join.to_i + DIVIDING_VALUE * 2))}".chars : digits
      end

      def to_i
        return self.to_digits.join.to_i
      end

      def to_s
        "#{self}"
      end
    end
  end
end
