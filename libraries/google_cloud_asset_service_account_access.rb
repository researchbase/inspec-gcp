# frozen_string_literal: false

require 'gcp_backend'

# Resources a service account can access, discovered through Cloud Asset
# Inventory: direct IAM bindings on any resource in the project, plus
# resources carrying a tag named in a tag-conditioned project-level binding
# (resource.matchTag / resource.matchTagId). Results are cached per
# project/service account so the lookup runs once per audit regardless of how
# many controls consult it.
#
# Usage:
#   access = google_cloud_asset_service_account_access(project: 'my-project', service_account: 'app@my-project.iam.gserviceaccount.com')
#   describe access do
#     it { should exist }
#     it { should be_accessible('/services/my-service') }
#     its('error') { should be_nil }
#   end
class GoogleCloudAssetServiceAccountAccess < GcpResourceBase
  name 'google_cloud_asset_service_account_access'
  desc 'Cloud Asset Inventory — resources accessible by a service account through direct or tag-conditioned IAM bindings'
  supports platform: 'gcp'

  # resource.matchTag("org/env", "production") and
  # resource.matchTagId("tagKeys/123", "tagValues/456") in IAM conditions.
  MATCH_TAG = /resource\.matchTag\(\s*["'][^"']+["']\s*,\s*["']([^"']+)["']\s*\)/.freeze
  MATCH_TAG_ID = %r{resource\.matchTagId\(\s*["'][^"']+["']\s*,\s*["'](tagValues/\d+)["']\s*\)}.freeze

  # A constant rather than a class instance variable: InSpec instantiates an
  # anonymous subclass of this resource, which would not see the ivar. It is
  # deliberately mutable: it is the per-run memo of lookups.
  CACHE = {} # rubocop:disable Style/MutableConstant

  attr_reader :params, :project, :service_account, :resources, :error

  def initialize(params)
    super(params.merge({ use_http_transport: true }))
    @params = params
    @resources = []
    @error = nil
    @project = params.fetch(:project)
    @service_account = params.fetch(:service_account)
    @resources, @error = CACHE[[project, service_account]] ||= fetch
  end

  def exists?
    !resources.empty?
  end

  # True when any accessible resource's full name ends with `suffix`, e.g.
  # '/services/my-service' or '//storage.googleapis.com/my-bucket'.
  def accessible?(suffix)
    resources.any? { |resource| resource.end_with?(suffix) }
  end

  def count
    resources.length
  end

  def to_s
    "Service account access for #{service_account}"
  end

  private

  # Returns [resources, error]. A failed lookup degrades to whatever was
  # discovered so dependent controls fail with a resource-level message,
  # and records the error so a control can report the root cause.
  def fetch
    resources = []

    direct = checked(inspec.google_cloud_asset_iam_policies(project: project, query: "policy:#{service_account}"))
    resources += direct.resources

    tag_queries.each do |query|
      tagged = checked(inspec.google_cloud_asset_resources(project: project, query: query))
      resources += tagged.names
    end

    [resources.uniq, nil]
  rescue StandardError => e
    error = "#{e.class}: #{e.message.lines.first.to_s.strip[0, 200]}"
    Inspec::Log.warn("#{self}: lookup failed: #{error}")
    [resources.uniq, error]
  end

  # Asset search queries for every tag named in a tag-conditioned project
  # binding that grants the service account a role.
  def tag_queries
    policy = checked(inspec.google_project_iam_policy(project: project))
    (policy.bindings || []).flat_map do |binding|
      next [] unless (binding.members || []).include?("serviceAccount:#{service_account}")

      expression = binding.condition&.expression || ''
      expression.scan(MATCH_TAG).map { |(value)| "tagValues:#{value}" } +
        expression.scan(MATCH_TAG_ID).map { |(id)| "tagValueIds:#{id}" }
    end.uniq
  end

  # inspec-gcp swallows API errors into the resource's failed/skipped state
  # instead of raising, which would otherwise read as "no results".
  def checked(resource)
    if resource.resource_failed? || resource.resource_skipped?
      raise "#{resource} failed: #{resource.resource_exception_message}"
    end

    resource
  end
end
