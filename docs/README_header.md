# HCP Terraform Foundation

Code which manages configuration and life-cycle of all the HCP Terraform
foundation. It is designed to be used from a dedicated VCS-Driven Terraform
workspace that would provision and manage the configuration using
Terraform code (IaC).

## Permissions

### HCP Terraform Permissions

To manage the resources from that code, provide a token from an account with
`owner` permissions. Alternatively, you can use a token from the `owner` team
instead of a user token.

### Azure DevOps Permissions

To manage the Azure DevOps resources, provide a Personal Access Token (PAT) or
configure a service principal with appropriate permissions. The identity must have:

* **Code**: Read & Write (to create and configure repositories)
* **Project and Team**: Read (to read project information)
* **Build**: Read & Execute (required for branch policies that reference build definitions)

## Authentication

### HCP Terraform Authentication

The HCP Terraform provider requires a HCP Terraform/Terraform Enterprise API token in
order to manage resources.

There are several ways to provide the required token:

* Set the `token` argument in the provider configuration. You can set the token argument in the provider configuration. Use an
input variable for the token.
* Set the `TFE_TOKEN` environment variable. The provider can read the TFE_TOKEN environment variable and the token stored there
to authenticate.

### Azure DevOps Authentication

The Azure DevOps provider requires a Personal Access Token (PAT) or service principal credentials
in order to manage resources.

There are several ways to provide the required credentials:

* Set the `AZDO_ORG_SERVICE_URL` environment variable to your Azure DevOps organization URL
  (e.g., `https://dev.azure.com/your-org`).
* Set the `AZDO_PERSONAL_ACCESS_TOKEN` environment variable to authenticate with a PAT.

Alternatively, for service principal (OIDC/client secret) authentication, set:
* `AZDO_CLIENT_ID` – the service principal client ID.
* `AZDO_CLIENT_SECRET` or configure OIDC with `AZDO_TENANT_ID`.

> **Note:** The PAT must be created with the scopes listed under **Azure DevOps Permissions** above.
> Token TTL should be set according to your organization's security policy.

## Features

* Manages configuration and life-cycle of HCP Terraform resources:
  * projects
  * workspaces
  * teams
  * variable sets
  * variables
  * notifications
  * run tasks
* Manages Azure DevOps repository configuration:
  * Git repositories (one per factory workspace)
  * Branch policies (minimum reviewers, comment resolution, merge types, auto reviewers)

## Prerequisite

In order to deploy the configuration from this code, you must first create
an organization. You must then configure a [VCS Provider](https://github.com/benoitblais-hashicorp/HCPTerraform-Foundation/blob/main/docs/VCS-Provider.md)
before manually creating a dedicated VCS-driven workspace in the UI.

To authenticate into HCP Terraform during configuration deployment, an
API token must be created. This token must come from an account with `owner`
permission or the `owner` team. An environment variable `TFE_TOKEN` must be
created in the previously created workspace with the value of the generated token.

The Azure DevOps project (`azuredevops_project_id`) must already exist before
this module is applied. Repositories will be created inside that project.

## Manual Configurations

Currently, there are some HCP Terraform organization-level settings that are not fully exposed or supported by the `hashicorp/tfe` Terraform provider and must be configured manually via the HCP Terraform UI:

1. **Maximum Time To Live (TTL) for API Tokens**: You can configure a maximum TTL for user and team API tokens to enhance security. This must be set manually in your Organization Settings.
2. **Recoverable Items (Data Retention Policy)**: Enabling or configuring the retention window for deleted (recoverable) workspaces, networks, or other items is not yet possible through Terraform.
3. **IP Allow List (Inbound Allow List)**: Restricting inbound access to HCP Terraform workspaces and API endpoints to specific IP ranges must be done natively in the UI.
