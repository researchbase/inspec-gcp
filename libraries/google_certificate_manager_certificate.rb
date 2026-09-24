# frozen_string_literal: false

require 'gcp_backend'
require 'google/certificatemanager/property/certificate_managed'

# A provider to manage Certificate Manager certificate resources.
#
# Usage:
#   describe google_certificate_manager_certificate(project: 'my-project', location: 'global', name: 'my-cert') do
#     it { should exist }
#     it { should be_managed }
#     its('managed.state') { should eq 'ACTIVE' }
#     its('days_until_expiry') { should be > 14 }
#   end
class CertificateManagerCertificate < GcpResourceBase
  name 'google_certificate_manager_certificate'
  desc 'Certificate Manager Certificate'
  supports platform: 'gcp'

  attr_reader :params
  attr_reader :name
  attr_reader :description
  attr_reader :labels
  attr_reader :scope
  attr_reader :san_dnsnames
  attr_reader :pem_certificate
  attr_reader :managed
  attr_reader :self_managed
  attr_reader :create_time
  attr_reader :update_time
  attr_reader :expire_time
  attr_reader :used_by

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
    @scope = @fetched['scope']
    @san_dnsnames = @fetched['sanDnsnames']
    @pem_certificate = @fetched['pemCertificate']
    @managed = GoogleInSpec::CertificateManager::Property::CertificateManaged.new(@fetched['managed'], to_s)
    @self_managed = @fetched['selfManaged']
    @create_time = parse_time_string(@fetched['createTime'])
    @update_time = parse_time_string(@fetched['updateTime'])
    @expire_time = parse_time_string(@fetched['expireTime'])
    @used_by = (@fetched['usedBy'] || []).map { |u| u['name'] }
  end

  # Google-managed certificate (`managed` block present in the API response).
  def managed?
    !@fetched.nil? && @fetched.key?('managed')
  end

  # Customer-uploaded certificate (`selfManaged` block present in the API response).
  def self_managed?
    !@fetched.nil? && @fetched.key?('selfManaged')
  end

  # Whole days until expireTime; nil when the certificate has not been issued yet.
  def days_until_expiry
    return nil if @expire_time.nil?

    ((@expire_time - Time.now) / 86_400).floor
  end

  # Handles parsing RFC3339 time string
  def parse_time_string(time_string)
    time_string ? Time.parse(time_string) : nil
  end

  def exists?
    !@fetched.nil?
  end

  def to_s
    "Certificate Manager Certificate #{@params[:name]}"
  end

  private

  def product_url(_ = nil)
    'https://certificatemanager.googleapis.com/v1/'
  end

  def resource_base_url
    'projects/{{project}}/locations/{{location}}/certificates/{{name}}'
  end
end
