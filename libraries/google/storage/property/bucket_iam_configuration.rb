# frozen_string_literal: false

module GoogleInSpec
  module Storage
    module Property
      class BucketIamConfigurationUniformBucketLevelAccess
        attr_reader :enabled

        attr_reader :locked_time

        def initialize(args = nil, parent_identifier = nil)
          return if args.nil?
          @parent_identifier = parent_identifier
          @enabled = args['enabled']
          @locked_time = args['lockedTime']
        end

        def to_s
          "#{@parent_identifier} UniformBucketLevelAccess"
        end
      end

      class BucketIamConfiguration
        attr_reader :uniform_bucket_level_access

        attr_reader :public_access_prevention

        def initialize(args = nil, parent_identifier = nil)
          return if args.nil?
          @parent_identifier = parent_identifier
          @uniform_bucket_level_access = BucketIamConfigurationUniformBucketLevelAccess.new(args['uniformBucketLevelAccess'], to_s)
          @public_access_prevention = args['publicAccessPrevention']
        end

        def to_s
          "#{@parent_identifier} BucketIamConfiguration"
        end
      end
    end
  end
end
