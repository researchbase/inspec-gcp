+++
title = "google_certificate_manager_certificate_map resource"

draft = false


[menu.gcp]
title = "google_certificate_manager_certificate_map"
identifier = "inspec/resources/gcp/google_certificate_manager_certificate_map resource"
parent = "inspec/resources/gcp"
+++

## Syntax

A `google_certificate_manager_certificate_map` is used to test a Certificate Manager CertificateMap resource

## Examples

```ruby
describe google_certificate_manager_certificate_map(project: 'chef-gcp-inspec', location: 'global', name: 'inspec-gcp-map') do
  it { should exist }
  its('gclb_targets') { should include '//compute.googleapis.com/projects/chef-gcp-inspec/global/targetHttpsProxies/inspec-gcp-proxy' }
end
```

## Properties

Properties that can be accessed from the `google_certificate_manager_certificate_map` resource:

  * `name`: Full resource name of the certificate map.

  * `description`: One or more paragraphs of text description of a certificate map.

  * `labels`: Set of labels associated with a Certificate Map.

  * `create_time`: The creation timestamp of a Certificate Map.

  * `update_time`: The update timestamp of a Certificate Map.

  * `gclb_targets`: Resource names of the target HTTPS/SSL proxies that use this Certificate Map.

## GCP Permissions

Ensure the [Certificate Manager API](https://console.cloud.google.com/apis/library/certificatemanager.googleapis.com/) is enabled for the current project.
