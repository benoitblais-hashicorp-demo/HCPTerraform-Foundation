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
