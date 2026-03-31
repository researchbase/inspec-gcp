# frozen_string_literal: false

module GoogleInSpec
  module SQL
    module Property
      class DatabaseInstanceSettingsMaintenanceWindow
        attr_reader :day

        attr_reader :hour

        attr_reader :update_track

        def initialize(args = nil, parent_identifier = nil)
          return if args.nil?
          @parent_identifier = parent_identifier
          @day = args['day']
          @hour = args['hour']
          @update_track = args['updateTrack']
        end

        def to_s
          "#{@parent_identifier} DatabaseInstanceSettingsMaintenanceWindow"
        end
      end
    end
  end
end
