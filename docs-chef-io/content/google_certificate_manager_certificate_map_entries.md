+++
title = "google_certificate_manager_certificate_map_entries resource"

draft = false


[menu.gcp]
title = "google_certificate_manager_certificate_map_entries"
identifier = "inspec/resources/gcp/google_certificate_manager_certificate_map_entries resource"
parent = "inspec/resources/gcp"
+++

## Syntax

A `google_certificate_manager_certificate_map_entries` is used to test the CertificateMapEntry resources of a Certificate Manager CertificateMap

## Examples

```ruby
entries = google_certificate_manager_certificate_map_entries(project: 'chef-gcp-inspec', location: 'global', certificate_map: 'inspec-gcp-map')

describe entries do
  its('count') { should be > 0 }
  its('states') { should all eq 'ACTIVE' }
  its('matchers') { should include 'PRIMARY' }
end

entries.certificate_names.each do |cert|
  describe google_certificate_manager_certificate(project: 'chef-gcp-inspec', location: 'global', name: cert) do
    its('managed.state') { should eq 'ACTIVE' }
  end
end
```

## Properties

Properties that can be accessed from the `google_certificate_manager_certificate_map_entries` resource:

  * `names`: an array of full certificate map entry resource names
  * `descriptions`: an array of entry descriptions
  * `hostnames`: an array of entry hostnames (nil for the PRIMARY matcher entry)
  * `matchers`: an array of entry matchers (PRIMARY or nil)
  * `states`: an array of entry serving states (ACTIVE or PENDING)
  * `certificates`: an array of arrays of full certificate resource names
  * `create_times`: an array of entry creation timestamps
  * `update_times`: an array of entry update timestamps

  * `certificate_names`: unique short names of every certificate referenced by any entry, suitable for `google_certificate_manager_certificate(name: ...)`

## Filter Criteria

This resource supports all of the above properties as filter criteria, which can be used
with `where` as a block or a method.

## GCP Permissions

Ensure the [Certificate Manager API](https://console.cloud.google.com/apis/library/certificatemanager.googleapis.com/) is enabled for the current project.
