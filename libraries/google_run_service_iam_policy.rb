# frozen_string_literal: false

require 'gcp_backend'
require 'google/iam/property/iam_policy_audit_configs'
require 'google/iam/property/iam_policy_bindings'

# A provider to manage Cloud Run v2 Service IAM Policy resources.
class RunServiceIamPolicy < GcpResourceBase
  name 'google_run_service_iam_policy'
  desc 'Cloud Run Service IAM Policy'
  supports platform: 'gcp'

  attr_reader :params
  attr_reader :bindings
  attr_reader :audit_configs

  def initialize(params)
    super(params.merge({ use_http_transport: true }))
    @params = params
    @fetched = @connection.fetch(product_url, resource_base_url, params, 'Get')
    parse unless @fetched.nil?
  end

  def parse
    @bindings = GoogleInSpec::Iam::Property::IamPolicyBindingsArray.parse(@fetched['bindings'], to_s)
    @audit_configs = GoogleInSpec::Iam::Property::IamPolicyAuditConfigsArray.parse(@fetched['auditConfigs'], to_s)
  end

  def exists?
    !@fetched.nil?
  end

  def to_s
    "Run Service IamPolicy #{@params[:name]}"
  end

  def iam_binding_roles
    @bindings.map(&:role)
  end

  def count
    @bindings.size
  end

  private

  def product_url(_ = nil)
    'https://run.googleapis.com/v2/'
  end

  def resource_base_url
    '{{name}}:getIamPolicy'
  end
end
