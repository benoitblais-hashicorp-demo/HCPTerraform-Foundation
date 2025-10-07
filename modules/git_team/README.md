# GitHub repository Terraform module

GitHub team module which manages configuration and life-cycle 
of all your GitHub teams configuration.

## Permissions

To manage the GitHub resources, provide a token from an account or a GitHub App with 
appropriate permissions. It should have:

* Read access to `metadata`
* Read and write access to `administration`, and `members`

## Authentication

The GitHub provider requires a GitHub token or GitHub App installation in order to manage resources.

There are several ways to provide the required token:

- Set the `token` argument in the provider configuration. You can set the `token` argument in the provider configuration. Use an
input variable for the token.
- Set the `GITHUB_TOKEN` environment variable. The provider can read the `GITHUB_TOKEN` environment variable and the token stored there
to authenticate.

There are several ways to provide the required GitHub App installation:

- Set the `app_auth` argument in the provider configuration. You can set the app_auth argument with the id, installation_id and pem_file
in the provider configuration. The owner parameter is also required in this situation.
- Set the `GITHUB_APP_ID`, `GITHUB_APP_INSTALLATION_ID` and `GITHUB_APP_PEM_FILE` environment variables. The provider can read the GITHUB_APP_ID,
GITHUB_APP_INSTALLATION_ID and GITHUB_APP_PEM_FILE environment variables to authenticate.

> Because strings with new lines is not support:</br>
> use "\\\n" within the `pem_file` argument to replace new line</br>
> use "\n" within the `GITHUB_APP_PEM_FILE` environment variables to replace new line</br>

## Features

- Create and manage team within your GitHub organization or personal account.
- Create and manage team permissions on a particular repository.

## Usage example
```hcl
module "team" {
  source = "./modules/git_team"

  name        = "Team Name"
  description = "This is a description for the GitHub team."
  permission  = "push"
  repository  = "Repository Name"
}
```

<!-- BEGIN_TF_DOCS -->
## Requirements

The following requirements are needed by this module:

- <a name="requirement_terraform"></a> [terraform](#requirement\_terraform) (>= 1.13.0)

- <a name="requirement_github"></a> [github](#requirement\_github) (6.6.0)

## Providers

The following providers are used by this module:

- <a name="provider_github"></a> [github](#provider\_github) (6.6.0)

## Modules

No modules.

## Resources

The following resources are used by this module:

- [github_team.this](https://registry.terraform.io/providers/integrations/github/6.6.0/docs/resources/team) (resource)
- [github_team_repository.this](https://registry.terraform.io/providers/integrations/github/6.6.0/docs/resources/team_repository) (resource)

## Required Inputs

The following input variables are required:

### <a name="input_name"></a> [name](#input\_name)

Description: (Required) The name of the team.

Type: `string`

## Optional Inputs

The following input variables are optional (have default values):

### <a name="input_create_default_maintainer"></a> [create\_default\_maintainer](#input\_create\_default\_maintainer)

Description: (Optional) Adds a default maintainer to the team. Defaults to `false` and adds the creating user to the team when `true`.

Type: `bool`

Default: `false`

### <a name="input_description"></a> [description](#input\_description)

Description: (Optional) A description of the team.

Type: `string`

Default: `null`

### <a name="input_ldap_dn"></a> [ldap\_dn](#input\_ldap\_dn)

Description: (Optional) The LDAP Distinguished Name of the group where membership will be synchronized. Only available in GitHub Enterprise Server.

Type: `string`

Default: `null`

### <a name="input_parent_team_id"></a> [parent\_team\_id](#input\_parent\_team\_id)

Description: (Optional) The ID or slug of the parent team, if this is a nested team.

Type: `string`

Default: `null`

### <a name="input_permission"></a> [permission](#input\_permission)

Description: (Optional) The permissions of team members regarding the repository. Must be one of pull, triage, push, maintain, admin or the name of an existing custom repository role within the organisation.

Type: `string`

Default: `"pull"`

### <a name="input_privacy"></a> [privacy](#input\_privacy)

Description: (Optional) The level of privacy for the team. Must be one of `secret` or `closed`.

Type: `string`

Default: `"secret"`

### <a name="input_repository"></a> [repository](#input\_repository)

Description: (Optional) The name of the repository to add to the team.

Type: `string`

Default: `null`

## Outputs

The following outputs are exported:

### <a name="output_id"></a> [id](#output\_id)

Description: The ID of the created team.

### <a name="output_node_id"></a> [node\_id](#output\_node\_id)

Description: The Node ID of the created team.

### <a name="output_slug"></a> [slug](#output\_slug)

Description: The slug of the created team, which may or may not differ from name, depending on whether name contains "URL-unsafe" characters. Useful when referencing the team in github\_branch\_protection.

### <a name="output_team"></a> [team](#output\_team)

Description: GitHub team resource.
<!-- END_TF_DOCS -->