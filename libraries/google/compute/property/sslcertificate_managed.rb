# frozen_string_literal: false

module GoogleInSpec
  module Compute
    module Property
      class SslCertificateManaged
        attr_reader :status

        attr_reader :domains

        attr_reader :domain_status

        def initialize(args = nil, parent_identifier = nil)
          return if args.nil?
          @parent_identifier = parent_identifier
          @status = args['status']
          @domains = args['domains']
          @domain_status = args['domainStatus']
        end

        def to_s
          "#{@parent_identifier} SslCertificateManaged"
        end
      end
    end
  end
end
