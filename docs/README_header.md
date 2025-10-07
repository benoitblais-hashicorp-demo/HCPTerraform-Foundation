# HCP Terraform Foundation

Code which manages configuration and life-cycle of all the HCP Terraform
foundation. It is designed to be used from a dedicated VCS-Driven Terraform
Cloud workspace that would provision and manage the configuration using
Terraform code (IaC).

## Permissions

### Terraform Cloud Permissions

To manage the resources from that code, provide a token from an account with
`owner` permissions. Alternatively, you can use a token from the `owner` team
instead of a user token.

## Authentication

### Terraform Cloud Authentication

The Terraform Cloud provider requires a Terraform Cloud/Enterprise API token in
order to manage resources.

* Set the `TFE_TOKEN` environment variable: The provider can read the TFE_TOKEN
environment variable and the token stored there to authenticate. Refer to
[Managing Variables](https://developer.hashicorp.com/terraform/cloud-docs/workspaces/variables/managing-variables) documentation for more details.

## Features

* Manages configuration and life-cycle of Terraform Cloud resources:
  * projects
  * workspaces
  * teams
  * variable sets
  * variables
  * notifications
  * run tasks

## Prerequisite

In order to deploy the configuration from this code, you must first create
an organization. You must then configure a [VCS Provider](https://github.com/benoitblais-hashicorp/HCPTerraform-Foundation/blob/main/docs/VCS-Provider.md)
before manually creating a dedicated VCS-driven workspace in the UI.

To authenticate into Terraform Cloud during configuration deployment, an
API token must be created. This token must come from an account with `owner`
permission or the `owner` team. An environment variable `TFE_TOKEN` must be
created in the previously created workspace with the value of the generated token.
