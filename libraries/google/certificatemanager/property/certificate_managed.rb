# frozen_string_literal: false

module GoogleInSpec
  module CertificateManager
    module Property
      # The `managed` block of a Certificate Manager certificate.
      class CertificateManaged
        # PROVISIONING, FAILED or ACTIVE
        attr_reader :state

        attr_reader :domains

        attr_reader :dns_authorizations

        attr_reader :issuance_config

        # { 'reason' => 'AUTHORIZATION_ISSUE' | 'RATE_LIMITED', 'details' => '...' } or nil
        attr_reader :provisioning_issue

        # Array of { 'domain', 'state' (AUTHORIZING, AUTHORIZED, FAILED), 'failureReason', 'details' }
        attr_reader :authorization_attempt_info

        def initialize(args = nil, parent_identifier = nil)
          return if args.nil?
          @parent_identifier = parent_identifier
          @state = args['state']
          @domains = args['domains']
          @dns_authorizations = args['dnsAuthorizations']
          @issuance_config = args['issuanceConfig']
          @provisioning_issue = args['provisioningIssue']
          @authorization_attempt_info = args['authorizationAttemptInfo'] || []
        end

        # Domains whose latest authorization attempt did not reach AUTHORIZED.
        def unauthorized_domains
          @authorization_attempt_info.reject { |a| a['state'] == 'AUTHORIZED' }.map { |a| a['domain'] }
        end

        def to_s
          "#{@parent_identifier} CertificateManaged"
        end
      end
    end
  end
end
