# frozen_string_literal: false

require 'gcp_backend'

# Search all resources in a project scope for a given query.
#
# Usage:
#   describe google_cloud_asset_resources(project: 'my-project', query: 'tagValues:production') do
#     its('names') { should include '//storage.googleapis.com/my-bucket' }
#   end
class GoogleCloudAssetResources < GcpResourceBase
  name 'google_cloud_asset_resources'
  desc 'Cloud Asset Inventory — Search Resources'
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

  def names
    @results.map { |r| r['name'] }
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
    'projects/{{project}}:searchAllResources?query={{query}}'
  end
end
