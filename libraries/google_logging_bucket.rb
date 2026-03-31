# frozen_string_literal: false

require 'gcp_backend'

# A provider to manage Cloud Logging bucket resources.
class GoogleLoggingBucket < GcpResourceBase
  name 'google_logging_bucket'
  desc 'Cloud Logging Bucket'
  supports platform: 'gcp'

  attr_reader :params
  attr_reader :name
  attr_reader :description
  attr_reader :retention_days
  attr_reader :lifecycle_state
  attr_reader :create_time
  attr_reader :update_time
  attr_reader :locked

  def initialize(params)
    super(params.merge({ use_http_transport: true }))
    @params = params
    @fetched = @connection.fetch(product_url, resource_base_url, params, 'Get')
    parse unless @fetched.nil?
  end

  def parse
    @name = @fetched['name']
    @description = @fetched['description']
    @retention_days = @fetched['retentionDays']
    @lifecycle_state = @fetched['lifecycleState']
    @create_time = @fetched['createTime']
    @update_time = @fetched['updateTime']
    @locked = @fetched['locked']
  end

  def exists?
    !@fetched.nil?
  end

  def to_s
    "Logging Bucket #{@params[:name]}"
  end

  private

  def product_url(_ = nil)
    'https://logging.googleapis.com/v2/'
  end

  def resource_base_url
    'projects/{{project}}/locations/{{location}}/buckets/{{name}}'
  end
end
