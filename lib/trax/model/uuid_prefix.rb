module Trax
  module Model
    class UUIDPrefix < String
      HEX_LETTER_RANGE = ('a'..'f').to_a.freeze
      HEX_DIGIT_RANGE = (0..9).to_a.freeze
      CHARACTER_RANGE = (HEX_DIGIT_RANGE + HEX_LETTER_RANGE).freeze
      PREFIX_LENGTH = 2

      def self.all
        @all ||= begin
          CHARACTER_RANGE.repeated_permutation(PREFIX_LENGTH).to_a.reject! do |permutation|
              (HEX_LETTER_RANGE.include?(permutation[0]) && HEX_LETTER_RANGE.include?(permutation[1]) || HEX_DIGIT_RANGE.include?(permutation[0]) && HEX_DIGIT_RANGE.include?(permutation[1]))
          end.uniq.map do |character_array|
            new(character_array.join)
          end
        end
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

      def to_s
        "#{self}"
      end
    end
  end
end
