# frozen_string_literal: false

require 'gcp_backend'

# Search all IAM policies in a project scope for a given query.
#
# Usage:
#   describe google_cloud_asset_iam_policies(project: 'my-project', query: 'policy:sa@my-project.iam.gserviceaccount.com') do
#     its('resources') { should include '//run.googleapis.com/...' }
#   end
class GoogleCloudAssetIamPolicies < GcpResourceBase
  name 'google_cloud_asset_iam_policies'
  desc 'Cloud Asset Inventory — Search IAM Policies'
  supports platform: 'gcp'

  attr_reader :params
  attr_reader :results

  def initialize(params)
    super(params.merge({ use_http_transport: true }))
    @params = params
    @results = []
    fetch_results
  end

  def exists?
    !@results.empty?
  end

  def resources
    @results.map { |r| r['resource'] }
  end

  def count
    @results.length
  end

  private

  def fetch_results
    response = @connection.fetch_all(product_url, resource_base_url, @params, 'Get')
    return if response.nil?

    response.each do |page|
      next if page.nil? || !page.key?('results')
      @results += page['results']
    end
  end

  def product_url(_ = nil)
    'https://cloudasset.googleapis.com/v1/'
  end

  def resource_base_url
    'projects/{{project}}:searchAllIamPolicies?query={{query}}'
  end
end
