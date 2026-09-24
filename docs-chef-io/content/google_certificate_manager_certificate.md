+++
title = "google_certificate_manager_certificate resource"

draft = false


[menu.gcp]
title = "google_certificate_manager_certificate"
identifier = "inspec/resources/gcp/google_certificate_manager_certificate resource"
parent = "inspec/resources/gcp"
+++

## Syntax

A `google_certificate_manager_certificate` is used to test a Certificate Manager Certificate resource

## Examples

```ruby
describe google_certificate_manager_certificate(project: 'chef-gcp-inspec', location: 'global', name: 'inspec-gcp-cert') do
  it { should exist }
  it { should be_managed }
  its('managed.state') { should eq 'ACTIVE' }
  its('managed.unauthorized_domains') { should be_empty }
  its('days_until_expiry') { should be > 14 }
  its('san_dnsnames') { should include 'example.com' }
end
```

### Test that a Certificate Manager certificate does not exist

```ruby
describe google_certificate_manager_certificate(project: 'chef-gcp-inspec', location: 'global', name: 'nonexistent') do
  it { should_not exist }
end
```

## Properties

Properties that can be accessed from the `google_certificate_manager_certificate` resource:

  * `name`: Full resource name of the certificate.

  * `description`: One or more paragraphs of text description of a certificate.

  * `labels`: Set of labels associated with a Certificate.

  * `scope`: The scope of the certificate.
    Possible values:
    * DEFAULT
    * EDGE_CACHE
    * ALL_REGIONS
    * CLIENT_AUTH

  * `san_dnsnames`: The list of Subject Alternative Names of dnsName type defined in the certificate.

  * `pem_certificate`: The PEM-encoded certificate chain.

  * `expire_time`: The expiry timestamp of the certificate as a `Time`, or nil when not yet issued.

  * `days_until_expiry`: Whole days until `expire_time`, or nil when not yet issued.

  * `create_time`: The creation timestamp of a Certificate.

  * `update_time`: The last update timestamp of a Certificate.

  * `used_by`: Resource names (certificate map entries) that use this certificate.

  * `managed`: Configuration and state of a Google-managed certificate. Only populated when `managed?` is true.

    * `state`: State of the managed certificate resource.
      Possible values:
      * PROVISIONING
      * FAILED
      * ACTIVE

    * `domains`: The domains for which a managed SSL certificate will be generated.

    * `dns_authorizations`: Authorizations used for performing domain authorization.

    * `issuance_config`: The CertificateIssuanceConfig used to configure private PKI issuance.

    * `provisioning_issue`: Hash with `reason` (AUTHORIZATION_ISSUE, RATE_LIMITED) and `details`, or nil.

    * `authorization_attempt_info`: Array of hashes with `domain`, `state` (AUTHORIZING, AUTHORIZED, FAILED), `failureReason` and `details`.

    * `unauthorized_domains`: Domains whose latest authorization attempt is not AUTHORIZED.

  * `self_managed`: Present (as a Hash) for customer-uploaded certificates. Key material is input-only and never returned.

## Matchers

  * `be_managed`: The certificate is Google-managed.

  * `be_self_managed`: The certificate was uploaded by the customer.

## GCP Permissions

Ensure the [Certificate Manager API](https://console.cloud.google.com/apis/library/certificatemanager.googleapis.com/) is enabled for the current project.
