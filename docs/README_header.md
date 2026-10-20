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

### GitHub Permissions

To manage the GitHub resources, provide a token from an account or a GitHub App with
appropriate permissions. It should have:

* Read access to `metadata`
* Read and write access to `administration`, `code`, `secrets`, and `members`.

## Authentication

### HCP Terraform Authentication

The HCP Terraform provider requires a HCP Terraform/Terraform Enterprise API token in
order to manage resources.

There are several ways to provide the required token:

* Set the `token` argument in the provider configuration. You can set the token argument in the provider configuration. Use an
input variable for the token.
* Set the `TFE_TOKEN` environment variable. The provider can read the TFE_TOKEN environment variable and the token stored there
to authenticate.

### GitHub Authentication

The GitHub provider requires a GitHub token or GitHub App installation in order to manage resources.

There are several ways to provide the required token:

* Set the `token` argument in the provider configuration. You can set the `token` argument in the provider configuration. Use an
input variable for the token.
* Set the `GITHUB_TOKEN` environment variable. The provider can read the `GITHUB_TOKEN` environment variable and the token stored there
to authenticate.

There are several ways to provide the required GitHub App installation:

* Set the `app_auth` argument in the provider configuration. You can set the app_auth argument with the id, installation_id and pem_file
in the provider configuration. The owner parameter is also required in this situation.
* Set the `GITHUB_APP_ID`, `GITHUB_APP_INSTALLATION_ID` and `GITHUB_APP_PEM_FILE` environment variables. The provider can read the GITHUB_APP_ID,
GITHUB_APP_INSTALLATION_ID and GITHUB_APP_PEM_FILE environment variables to authenticate.

> Because strings with new lines is not support:</br>
> use "\\\n" within the `pem_file` argument to replace new line</br>
> use "\n" within the `GITHUB_APP_PEM_FILE` environment variables to replace new line</br>

## Features

* Manages configuration and life-cycle of HCP Terraform resources:
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

To authenticate into HCP Terraform during configuration deployment, an
API token must be created. This token must come from an account with `owner`
permission or the `owner` team. An environment variable `TFE_TOKEN` must be
created in the previously created workspace with the value of the generated token.

## Manual Configurations

Currently, there are some HCP Terraform settings that are not fully exposed or supported by the `hashicorp/tfe` Terraform provider and must be configured manually via the HCP Terraform UI:

1. **Recoverable Items (Data Retention Policy)**: Enabling or configuring the retention window for deleted (recoverable) workspaces, networks, or other items is not yet possible through Terraform.
2. **IP Allow List (Inbound Allow List)**: Restricting inbound access to HCP Terraform workspaces and API endpoints to specific IP ranges must be done natively in the UI.
3. **External Email Recipients (Project Notifications)**: Email notifications to recipients outside the organization are not yet configurable through Terraform, because email_addresses is only available on Terraform Enterprise. Only organization members (email_users) can be set in code. Add external recipients manually in the project's notification settings in the UI.
4. **Reserved Keys (Workspace Tag Keys)**: Reserved tag keys — such as keys that HCP Terraform treats as system-managed — cannot be created or managed through Terraform. If your organization requires reserved keys, they must be configured directly through the HCP Terraform UI under **Settings → Tag Keys**.
