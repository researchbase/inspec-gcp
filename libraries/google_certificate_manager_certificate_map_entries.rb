# frozen_string_literal: false

require 'gcp_backend'

# Entries of a Certificate Manager certificate map, each binding a hostname
# (or the PRIMARY matcher) to one or more certificates.
#
# Usage:
#   entries = google_certificate_manager_certificate_map_entries(project: 'my-project', location: 'global', certificate_map: 'my-map')
#   describe entries do
#     its('count') { should be > 0 }
#     its('states') { should all eq 'ACTIVE' }
#   end
#   entries.certificate_names.each do |cert|
#     describe google_certificate_manager_certificate(project: 'my-project', location: 'global', name: cert) do
#       its('managed.state') { should eq 'ACTIVE' }
#     end
#   end
class CertificateManagerCertificateMapEntries < GcpResourceBase
  name 'google_certificate_manager_certificate_map_entries'
  desc 'Certificate Manager Certificate Map Entry plural resource'
  supports platform: 'gcp'

  attr_reader :table

  filter_table_config = FilterTable.create

  filter_table_config.add(:names, field: :name)
  filter_table_config.add(:descriptions, field: :description)
  filter_table_config.add(:hostnames, field: :hostname)
  filter_table_config.add(:matchers, field: :matcher)
  filter_table_config.add(:states, field: :state)
  filter_table_config.add(:certificates, field: :certificates)
  filter_table_config.add(:create_times, field: :create_time)
  filter_table_config.add(:update_times, field: :update_time)

  filter_table_config.connect(self, :table)

  def initialize(params = {})
    super(params.merge({ use_http_transport: true }))
    @params = params
    @table = fetch_wrapped_resource('certificateMapEntries')
  end

  # Unique short names of every certificate referenced by any entry, for use
  # with google_certificate_manager_certificate(name: ...).
  def certificate_names
    (@table || []).flat_map { |entry| entry[:certificates] || [] }.map { |ref| ref.split('/').last }.uniq
  end

  def fetch_wrapped_resource(wrap_path)
    # fetch_resource returns an array of responses (to handle pagination)
    result = @connection.fetch_all(product_url, resource_base_url, @params, 'Get')
    return if result.nil?

    # Conversion of string -> object hash to symbol -> object hash that InSpec needs
    converted = []
    result.each do |response|
      next if response.nil? || !response.key?(wrap_path)
      response[wrap_path].each do |hash|
        hash_with_symbols = {}
        hash.each_key do |key|
          name, value = transform(key, hash)
          hash_with_symbols[name] = value
        end
        converted.push(hash_with_symbols)
      end
    end

    converted
  end

  def transform(key, value)
    return transformers[key].call(value) if transformers.key?(key)

    [key.to_sym, value]
  end

  def transformers
    {
      'name' => ->(obj) { [:name, obj['name']] },
      'description' => ->(obj) { [:description, obj['description']] },
      'hostname' => ->(obj) { [:hostname, obj['hostname']] },
      'matcher' => ->(obj) { [:matcher, obj['matcher']] },
      'state' => ->(obj) { [:state, obj['state']] },
      'certificates' => ->(obj) { [:certificates, obj['certificates']] },
      'labels' => ->(obj) { [:labels, obj['labels']] },
      'createTime' => ->(obj) { [:create_time, parse_time_string(obj['createTime'])] },
      'updateTime' => ->(obj) { [:update_time, parse_time_string(obj['updateTime'])] },
    }
  end

  # Handles parsing RFC3339 time string
  def parse_time_string(time_string)
    time_string ? Time.parse(time_string) : nil
  end

  private

  def product_url(_ = nil)
    'https://certificatemanager.googleapis.com/v1/'
  end

  def resource_base_url
    'projects/{{project}}/locations/{{location}}/certificateMaps/{{certificate_map}}/certificateMapEntries'
  end
end
