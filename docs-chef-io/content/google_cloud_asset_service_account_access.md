+++
title = "google_cloud_asset_service_account_access resource"

draft = false


[menu.gcp]
title = "google_cloud_asset_service_account_access"
identifier = "inspec/resources/gcp/google_cloud_asset_service_account_access resource"
parent = "inspec/resources/gcp"
+++

## Syntax

A `google_cloud_asset_service_account_access` lists the resources a service account can access in a project, discovered through Cloud Asset Inventory:

* resources with a direct IAM binding for the service account (`searchAllIamPolicies` with `policy:<service_account>`), and
* resources carrying a tag that a tag-conditioned project-level binding (`resource.matchTag(...)` / `resource.matchTagId(...)`) grants the service account access through.

Results are cached per project and service account for the life of the run, so many controls can consult the same lookup at the cost of one set of API calls.

## Examples

```ruby
access = google_cloud_asset_service_account_access(project: 'chef-gcp-inspec', service_account: 'app@chef-gcp-inspec.iam.gserviceaccount.com')

describe access do
  it { should exist }
  its('error') { should be_nil }
  it { should be_accessible('/services/app-web') }
  it { should be_accessible('//storage.googleapis.com/app-uploads') }
end
```

## Properties

  * `resources`: full resource names (e.g. `//run.googleapis.com/projects/p/locations/l/services/s`) the service account can access
  * `count`: number of accessible resources
  * `error`: nil, or a message describing why the lookup was incomplete (e.g. Cloud Asset API disabled or permission denied). Resources discovered before the failure are still returned.

## Matchers

  * `be_accessible(suffix)`: true when any accessible resource name ends with `suffix`

## GCP Permissions

Ensure the [Cloud Asset API](https://console.cloud.google.com/apis/library/cloudasset.googleapis.com/) is enabled for the current project. The caller needs `cloudasset.assets.searchAllIamPolicies`, `cloudasset.assets.searchAllResources` and `resourcemanager.projects.getIamPolicy` on the project.
