module Trax
  module Model
    class UUIDArray < SimpleDelegator
      attr_reader :uuids

      def initialize(*uuids)
        @uuids = uuids.map{ |uuid_string| uuid_string.try(&:uuid) }.compact
      end

      def each(&block)
        yield @uuids.each(&block)
      end

      def __getobj__
        @uuids
      end

      def <<(val)
        reset_instance_variables(:record_types, :records_grouped_by_count, :records_grouped_by_uuid)

        if val.is_a?(::Trax::Model::UUID)
          @uuids << val
        else
          @uuids << ::Trax::Model::UUID.new(val)
        end
      end

      #removing this line appears to be what was causing the duplication
      def to_a
        @uuids
      end

      def records
        @records ||= group_by_record_type.to_a.map{|pair|
          pair[0].by_id(*pair[1])
        }.flatten.compact
      end

      def records_grouped_by_uuid
        @records_grouped_by_uuid ||= records.group_by(&:id)
      end

      def records_grouped_by_count
        @records_grouped_by_count ||= begin
          {}.tap do |hash|
            @uuids.group_by_count.each_pair do |uuid, count|
              record = records_grouped_by_uuid[uuid].first
              hash[record] = count
            end

            hash
          end
        end
      end

      private

      def group_by_count
        @uuids.group_by(&:count)
      end

      def group_by_record_type
        @uuids.group_by{ |uuid| uuid.record_type }
      end

      def record_types
        @record_types ||= @uuids.map(&:record_type).flatten.compact.uniq
      end
    end
  end
end
