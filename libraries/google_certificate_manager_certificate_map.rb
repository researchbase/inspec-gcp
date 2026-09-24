# frozen_string_literal: false

require 'gcp_backend'

# A provider to manage Certificate Manager certificate map resources.
#
# Usage:
#   describe google_certificate_manager_certificate_map(project: 'my-project', location: 'global', name: 'my-map') do
#     it { should exist }
#     its('gclb_targets') { should_not be_empty }
#   end
class CertificateManagerCertificateMap < GcpResourceBase
  name 'google_certificate_manager_certificate_map'
  desc 'Certificate Manager Certificate Map'
  supports platform: 'gcp'

  attr_reader :params
  attr_reader :name
  attr_reader :description
  attr_reader :labels
  attr_reader :create_time
  attr_reader :update_time
  # Target proxies serving this map, e.g. //compute.googleapis.com/projects/p/global/targetHttpsProxies/x
  attr_reader :gclb_targets

  def initialize(params)
    super(params.merge({ use_http_transport: true }))
    @params = params
    @fetched = @connection.fetch(product_url, resource_base_url, params, 'Get')
    parse unless @fetched.nil?
  end

  def parse
    @name = @fetched['name']
    @description = @fetched['description']
    @labels = @fetched['labels']
    @create_time = parse_time_string(@fetched['createTime'])
    @update_time = parse_time_string(@fetched['updateTime'])
    @gclb_targets = (@fetched['gclbTargets'] || []).map { |t| t['targetHttpsProxy'] || t['targetSslProxy'] }.compact
  end

  # Handles parsing RFC3339 time string
  def parse_time_string(time_string)
    time_string ? Time.parse(time_string) : nil
  end

  def exists?
    !@fetched.nil?
  end

  def to_s
    "Certificate Manager Certificate Map #{@params[:name]}"
  end

  private

  def product_url(_ = nil)
    'https://certificatemanager.googleapis.com/v1/'
  end

  def resource_base_url
    'projects/{{project}}/locations/{{location}}/certificateMaps/{{name}}'
  end
end
