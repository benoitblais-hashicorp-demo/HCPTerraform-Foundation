# *********************************************************************************************** #
#                                      Required Variables                                         #
# *********************************************************************************************** #

variable "organization_email" {
  description = "(Required) Admin email address."
  type        = string
  nullable    = false
}

variable "organization_name" {
  description = "(Required) Name of the organization."
  type        = string
  nullable    = false
}

# *********************************************************************************************** #
#                                      Optional Variables                                         #
# *********************************************************************************************** #

variable "agent_pools" {
  description = "(Optional) A list with the name of all the agent pools available at the organization level."
  type        = list(string)
  nullable    = false
  default     = []
}

variable "aggregated_commit_status_enabled" {
  description = "(Optional) Whether or not to enable Aggregated Status Checks. This can be useful for monorepo repositories with multiple workspaces receiving status checks for events such as a pull request. If enabled, send_passing_statuses_for_untriggered_speculative_plans needs to be false. Default to `true`."
  type        = bool
  default     = true

  validation {
    condition     = var.aggregated_commit_status_enabled ? var.send_passing_statuses_for_untriggered_speculative_plans == false ? true : false : true
    error_message = "If `aggregated_commit_status_enabled` is enabled, `send_passing_statuses_for_untriggered_speculative_plans` needs to be false."
  }
}

variable "allow_force_delete_workspaces" {
  description = "(Optional) Whether workspace administrators are permitted to delete workspaces with resources under management. If false, only organization owners may delete these workspaces. Defaults to `false`."
  type        = bool
  default     = false
}

variable "assessments_enforced" {
  description = "(Optional) Whether to force health assessments (drift detection) on all eligible workspaces or allow workspaces to set their own preferences. Default to `true`."
  type        = bool
  default     = true
}

variable "audit_trail_token_max_ttl" {
  description = "(Optional) Maximum lifespan allowed for audit trail tokens to access the organization's resources. Format is <number><unit> (e.g., '0.5h', '3w', '6mo', '2y'). Defaults to null."
  type        = string
  nullable    = true
  default     = null
}

variable "collaborator_auth_policy" {
  description = "(Optional) Authentication policy. Valid values are `password` or `two_factor_mandatory`. Default to `two_factor_mandatory`."
  type        = string
  nullable    = false
  default     = "two_factor_mandatory"

  validation {
    condition     = contains(["password", "two_factor_mandatory"], var.collaborator_auth_policy) ? true : false
    error_message = "Valid values are \"password\" or \"two_factor_mandatory\"."
  }
}

variable "cost_estimation_enabled" {
  description = "(Optional) Whether or not the cost estimation feature is enabled for all workspaces in the organization. Defaults to `true`."
  type        = bool
  default     = true
}

variable "default_execution_mode" {
  description = "(Optional) Which execution mode to use as the default for all workspaces in the organization. Valid values are `remote`, `local` or `agent`. Default to `remote`."
  type        = string
  nullable    = false
  default     = "remote"

  validation {
    condition     = contains(["remote", "local", "agent"], var.default_execution_mode) ? true : false
    error_message = "Valid values are \"remote\", \"local\", or \"agent\"."
  }
}

variable "enforce_hyok" {
  description = "(Optional) (Available only in HCP Terraform) Whether HYOK is enabled for all new workspaces in the organization. Defaults to `false`."
  type        = bool
  default     = false
}

variable "hcp_foundation_project_agent_pool_name" {
  description = "(Optional) Name of the agent pool to create for the project in HCP Terraform. The agent pool is only created if the project is created and this variable is set. The agent pool is scoped to the project only."
  type        = string
  nullable    = true
  default     = null
}

variable "hcp_foundation_project_description" {
  description = "(Optional) A description for the project in HCP Terraform."
  type        = string
  nullable    = true
  default     = null
}

variable "hcp_foundation_project_name" {
  description = "(Optional) Name of the project in HCP Terraform."
  type        = string
  nullable    = true
  default     = "HCP Terraform"
}

variable "hcp_foundation_project_notification_configurations" {
  description = <<EOT
  (Optional) A list of notification configurations for the project in HCP Terraform. A project can have up to 20 notification configurations, and they apply to all runs of all workspaces within the project.
    name             : (Required) Name of the project notification configuration. Must be unique within the list.
    destination_type : (Required) The type of notification configuration payload to send. Valid values are `generic`, `email`, `slack`, and `microsoft-teams`.
    enabled          : (Optional) Whether the project notification configuration should be enabled or not. Disabled configurations will not send any notifications. Defaults to `false`.
    token            : (Optional) A secure token which can be used by the receiving server to verify request authenticity. Only valid when `destination_type` is `generic`. Cannot be used with `token_wo`.
    token_wo         : (Optional) Write-only alternative to `token`. Never stored in the Terraform state. Only valid when `destination_type` is `generic`. Cannot be used with `token`.
    token_wo_version : (Optional) Tracks the version of `token_wo`. Increment it to push a new `token_wo` value. Cannot be used with `token`.
    triggers         : (Optional) The list of triggers for which this notification configuration will send notifications. Valid values are `run:created`, `run:planning`, `run:needs_attention`, `run:pending_apply_approval`, `run:cost_estimated`, `run:policy_override_required`, `run:policies_checked`, `run:applying`, `run:completed`, `run:errored`, `run:run_errored`, `run:run_canceled`, `run:policy_soft_failed`, `assessment:check_failure`, `assessment:drifted`, `assessment:failed`, `workspace:auto_destroy_reminder`, or `workspace:auto_destroy_run_results`.
    url              : (Optional) The HTTP or HTTPS URL where notification requests will be made. Required if `destination_type` is `generic`, `microsoft-teams`, or `slack`. Must not be provided if `destination_type` is `email`. Cannot be used with `url_wo`.
    url_wo           : (Optional) Write-only alternative to `url`. Never stored in the Terraform state. Cannot be used with `url`.
    url_wo_version   : (Optional) Tracks the version of `url_wo`. Increment it to push a new `url_wo` value.
    email_users      : (Optional) A list of usernames of organization members who will receive the notification. Their user IDs are retrieved automatically. Each user must be a member of the organization. Only valid when `destination_type` is `email`.
  EOT
  type = list(object({
    name             = string
    destination_type = string
    enabled          = optional(bool, false)
    token            = optional(string)
    token_wo         = optional(string)
    token_wo_version = optional(number)
    triggers         = optional(set(string))
    url              = optional(string)
    url_wo           = optional(string)
    url_wo_version   = optional(number)
    email_users      = optional(set(string))
  }))
  sensitive = true
  nullable  = false
  default   = []

  validation {
    condition     = length([for config in var.hcp_foundation_project_notification_configurations : config.destination_type if contains(["generic", "email", "slack", "microsoft-teams"], config.destination_type)]) == length(var.hcp_foundation_project_notification_configurations)
    error_message = "Valid values for `destination_type` are \"generic\", \"email\", \"slack\", or \"microsoft-teams\"."
  }

  validation {
    condition     = length(distinct([for config in var.hcp_foundation_project_notification_configurations : config.name])) == length(var.hcp_foundation_project_notification_configurations)
    error_message = "Each notification configuration must have a unique `name`."
  }

  validation {
    condition     = length(var.hcp_foundation_project_notification_configurations) <= 20
    error_message = "A project can have up to 20 notification configurations."
  }
}

variable "hcp_foundation_project_tags" {
  description = "(Optional) A map of key-value tags to add to the project in HCP Terraform."
  type        = map(string)
  nullable    = true
  default = {
    environment = "production"
  }
}

variable "max_ttl_enabled" {
  description = "(Optional) Whether maximum token TTL policies are enabled for the organization. Defaults to `false`."
  type        = bool
  default     = false
}

variable "modules_factory_agent_pool_id" {
  description = "(Optional) The ID of an agent pool to assign to the workspace for the `modules factory`. Requires `execution_mode` to be set to `agent`. This value must not be provided if `execution_mode` is set to any other value."
  type        = string
  nullable    = true
  default     = null
}

variable "modules_factory_description" {
  description = "(Optional) A description for the workspacel for the `modules factory`."
  type        = string
  nullable    = true
  default     = "Code to provision and manage HCP Terraform modules using Terraform code (IaC)."
}

variable "modules_factory_execution_mode" {
  description = "(Optional) Which execution mode to use for the `modules factory`. Using Terraform Cloud, valid values are `remote`, `local` or `agent`. When set to `local`, the workspace will be used for state storage only. Important: If you omit this attribute, the resource configures the workspace to use your organization's default execution mode (which in turn defaults to `remote`), removing any explicit value that might have previously been set for the workspace."
  type        = string
  nullable    = true
  default     = null

  validation {
    condition     = var.modules_factory_execution_mode != null ? contains(["null", "remote", "local", "agent"], var.modules_factory_execution_mode) ? true : false : true
    error_message = "Valid values are \"remote\", \"local\" or \"agent\"."
  }
}

variable "modules_factory_github_teams" {
  description = <<EOT
  (Optional) The modules_factory_github_teams block supports the following:
    name        : (Required) The name of the team.
    description : (Optional) A description of the team.
    permission  : (Optional) The permissions of team members regarding the repository. Must be one of `pull`, `triage`, `push`, `maintain`, `admin` or the name of an existing custom repository role within the organisation.
  EOT
  type = list(object({
    name        = string
    description = optional(string)
    permission  = optional(string, "pull")
  }))
  nullable = false
  default = [{
    name        = "HCPTerraform-ModulesFactory-Contributors"
    description = "This group grant write access to the HCP Terraform modules repository."
    permission  = "push"
  }]
}

variable "modules_factory_tag" {
  description = "(Optional) A map of key value tags for this workspace for the `modules factory`."
  type        = map(string)
  nullable    = true
  default     = null
}

variable "modules_factory_workspace_name" {
  description = "(Optional) Name of the workspace for the `modules factory`."
  type        = string
  nullable    = true
  default     = "HCPTerraform-ModulesFactory"
}

variable "org_token_max_ttl" {
  description = "(Optional) Maximum lifespan allowed for organization tokens to access the organization's resources. Format is <number><unit> (e.g., '0.5h', '3w', '6mo', '2y'). Defaults to null."
  type        = string
  nullable    = true
  default     = null
}

variable "owners_team_saml_role_id" {
  description = "(Optional) The name of the \"owners\" team."
  type        = string
  nullable    = true
  default     = null
}

variable "policies_factory_agent_pool_id" {
  description = "(Optional) The ID of an agent pool to assign to the workspace for the `policies factory`. Requires `execution_mode` to be set to `agent`. This value must not be provided if `execution_mode` is set to any other value."
  type        = string
  nullable    = true
  default     = null
}

variable "policies_factory_description" {
  description = "(Optional) A description for the workspacel for the `policies factory`."
  type        = string
  nullable    = true
  default     = "Code to provision and manage HCP Terraform policies using Terraform code (IaC)."
}

variable "policies_factory_execution_mode" {
  description = "(Optional) Which execution mode to use for the `policies factory`. Using Terraform Cloud, valid values are `remote`, `local` or `agent`. When set to `local`, the workspace will be used for state storage only. Important: If you omit this attribute, the resource configures the workspace to use your organization's default execution mode (which in turn defaults to `remote`), removing any explicit value that might have previously been set for the workspace."
  type        = string
  nullable    = true
  default     = null

  validation {
    condition     = var.policies_factory_execution_mode != null ? contains(["null", "remote", "local", "agent"], var.policies_factory_execution_mode) ? true : false : true
    error_message = "Valid values are \"remote\", \"local\" or \"agent\"."
  }
}

variable "policies_factory_github_teams" {
  description = <<EOT
  (Optional) The policies_factory_github_teams block supports the following:
    name        : (Required) The name of the team.
    description : (Optional) A description of the team.
    permission  : (Optional) The permissions of team members regarding the repository. Must be one of `pull`, `triage`, `push`, `maintain`, `admin` or the name of an existing custom repository role within the organisation.
  EOT
  type = list(object({
    name        = string
    description = optional(string)
    permission  = optional(string, "pull")
  }))
  nullable = false
  default = [{
    name        = "HCPTerraform-Policies-Contributors"
    description = "This group grant write access to the HCP Terraform Policies repository."
    permission  = "push"
  }]
}

variable "policies_factory_tag" {
  description = "(Optional) A map of key value tags for this workspace for the `policies factory`."
  type        = map(string)
  nullable    = true
  default     = null
}

variable "policies_factory_workspace_name" {
  description = "(Optional) Name of the workspace for the `policies factory`."
  type        = string
  nullable    = true
  default     = "HCPTerraform-PoliciesFactory"
}

variable "projects_factory_agent_pool_id" {
  description = "(Optional) The ID of an agent pool to assign to the workspace for the `projects factory`. Requires `execution_mode` to be set to `agent`. This value must not be provided if `execution_mode` is set to any other value."
  type        = string
  nullable    = true
  default     = null
}

variable "projects_factory_description" {
  description = "(Optional) A description for the workspace for the `projects factory`."
  type        = string
  nullable    = true
  default     = "Code to provision and manage HCP Terraform projects using Terraform code (IaC)."
}

variable "projects_factory_execution_mode" {
  description = "(Optional) Which execution mode to use for the `projects factory`. Using Terraform Cloud, valid values are `remote`, `local` or `agent`. When set to `local`, the workspace will be used for state storage only. Important: If you omit this attribute, the resource configures the workspace to use your organization's default execution mode (which in turn defaults to `remote`), removing any explicit value that might have previously been set for the workspace."
  type        = string
  nullable    = true
  default     = null

  validation {
    condition     = var.projects_factory_execution_mode != null ? contains(["null", "remote", "local", "agent"], var.projects_factory_execution_mode) ? true : false : true
    error_message = "Valid values are \"remote\", \"local\" or \"agent\"."
  }
}

variable "projects_factory_github_teams" {
  description = <<EOT
  (Optional) The projects_factory_github_teams block supports the following:
    name        : (Required) The name of the team.
    description : (Optional) A description of the team.
    permission  : (Optional) The permissions of team members regarding the repository. Must be one of `pull`, `triage`, `push`, `maintain`, `admin` or the name of an existing custom repository role within the organisation.
  EOT
  type = list(object({
    name        = string
    description = optional(string)
    permission  = optional(string, "pull")
  }))
  nullable = false
  default = [{
    name        = "HCPTerraform-ProjectsFactory-Contributors"
    description = "This group grant write access to the HCP Terraform projects repository."
    permission  = "push"
  }]
}

variable "projects_factory_tag" {
  description = "(Optional) A map of key value tags for this workspace for the `projects factory`."
  type        = map(string)
  nullable    = true
  default     = null
}

variable "projects_factory_workspace_name" {
  description = "(Optional) Name of the workspace for the `projects factory`."
  type        = string
  nullable    = true
  default     = "HCPTerraform-ProjectsFactory"
}

variable "repositories_factory_agent_pool_id" {
  description = "(Optional) The ID of an agent pool to assign to the workspace for the `repositories factory`. Requires `execution_mode` to be set to `agent`. This value must not be provided if `execution_mode` is set to any other value."
  type        = string
  nullable    = true
  default     = null
}

variable "repositories_factory_description" {
  description = "(Optional) A description for the workspace for the `repositories factory`."
  type        = string
  nullable    = true
  default     = "Code to provision and manage GitHub repositories using Terraform code (IaC)."
}

variable "repositories_factory_execution_mode" {
  description = "(Optional) Which execution mode to use for the `repositories factory`. Using Terraform Cloud, valid values are `remote`, `local` or `agent`. When set to `local`, the workspace will be used for state storage only. Important: If you omit this attribute, the resource configures the workspace to use your organization's default execution mode (which in turn defaults to `remote`), removing any explicit value that might have previously been set for the workspace."
  type        = string
  nullable    = true
  default     = null

  validation {
    condition     = var.repositories_factory_execution_mode != null ? contains(["null", "remote", "local", "agent"], var.repositories_factory_execution_mode) ? true : false : true
    error_message = "Valid values are \"remote\", \"local\" or \"agent\"."
  }
}

variable "repositories_factory_github_teams" {
  description = <<EOT
  (Optional) The repositories_factory_github_teams block supports the following:
    name        : (Required) The name of the team.
    description : (Optional) A description of the team.
    permission  : (Optional) The permissions of team members regarding the repository. Must be one of `pull`, `triage`, `push`, `maintain`, `admin` or the name of an existing custom repository role within the organisation.
  EOT
  type = list(object({
    name        = string
    description = optional(string)
    permission  = optional(string, "pull")
  }))
  nullable = false
  default = [{
    name        = "HCPTerraform-repositoriesFactory-Contributors"
    description = "This group grant write access to the HCP Terraform repositories repository."
    permission  = "push"
  }]
}

variable "repositories_factory_tag" {
  description = "(Optional) A map of key value tags for this workspace for the `repositories factory`."
  type        = map(string)
  nullable    = true
  default     = null
}

variable "repositories_factory_workspace_name" {
  description = "(Optional) Name of the workspace for the `repositories factory`."
  type        = string
  nullable    = true
  default     = "GitHub-RepositoriesFactory"
}

variable "send_passing_statuses_for_untriggered_speculative_plans" {
  description = "(Optional) Whether or not to send VCS status updates for untriggered speculative plans. This can be useful if large numbers of untriggered workspaces are exhausting request limits for connected version control service providers like GitHub. Defaults to `false`."
  type        = bool
  default     = false
}

variable "session_remember_minutes" {
  description = "(Optional) Session expiration. Defaults to `20160`."
  type        = number
  nullable    = true
  default     = null
}

variable "session_timeout_minutes" {
  description = "(Optional) Session timeout after inactivity. Defaults to `20160`."
  type        = number
  nullable    = true
  default     = null
}

variable "speculative_plan_management_enabled" {
  description = "(Optional) Whether or not to enable Speculative Plan Management. If true, pending VCS-triggered speculative plans from outdated commits will be cancelled if a newer commit is pushed to the same branch. default to `true`."
  type        = bool
  default     = true
}

variable "stacks_enabled" {
  description = "(Optional) Whether or not to enable Stacks. Defaults to `true`."
  type        = bool
  default     = true
}

variable "team_token_max_ttl" {
  description = "(Optional) Maximum lifespan allowed for team tokens to access the organization's resources. Format is <number><unit> (e.g., '0.5h', '3w', '6mo', '2y'). Defaults to null."
  type        = string
  nullable    = true
  default     = null
}

variable "teams" {
  description = <<EOT
  (Optional) The teams block supports the following:
    name                          : (Required) Name of the team.
    allow_member_token_management : (Optional) Whether team members can manage team tokens. Used by Owners and users with Manage Teams permissions. Defaults to `true`.
    organization_access           : (Optional) The organization_access supports the following:
      access_secret_teams        : (Optional) Allow members access to secret teams up to the level of permissions granted by their team permissions setting.
      delegate_policy_overrides  : (Optional) When this setting is enabled for a team, its members can override failed policy evaluations on projects and workspaces they manage.
      manage_agent_pools         : (Optional) Allow members to create, edit, and delete agent pools within their organization.
      manage_membership          : (Optional) Allow members to add/remove users from the organization, and to add/remove users from visible teams.
      manage_modules             : (Optional) Allow members to publish and delete modules in the organization's private registry.
      manage_organization_access : (Optional) Allow members to update the organization access settings of teams.
      manage_policies            : (Optional) Allows members to create, edit, and delete the organization's Sentinel policies.
      manage_policy_overrides    : (Optional) Allows members to override soft-mandatory policy checks.
      manage_projects            : (Optional) Allow members to create and administrate all projects within the organization. Requires `manage_workspaces` to be set to `true`.
      manage_providers           : (Optional) Allow members to publish and delete providers in the organization's private registry.
      manage_run_tasks           : (Optional) Allow members to create, edit, and delete the organization's run tasks.
      manage_teams               : (Optional) Allow members to create, update, and delete teams.
      manage_vcs_settings        : (Optional) Allows members to manage the organization's VCS Providers and SSH keys.
      manage_workspaces          : (Optional) Allows members to create and administrate all workspaces within the organization.
      read_projects              : (Optional) Allow members to view all projects within the organization. Requires read_workspaces to be set to true.
      read_workspaces            : (Optional) Allow members to view all workspaces in this organization.
    sso_team_id                  : (Optional) Unique Identifier to control team membership via SAML.
    token                        : (Optional) If set to `true`, a team token will be generated.
    token_description            : (Optional) The token's description, which must be unique per team. Required if creating multiple tokens for a single team.
    token_expired_at             : (Optional) The token's expiration date. The expiration date must be a date/time string in RFC3339 format (e.g., '2024-12-31T23:59:59Z'). If no expiration date is supplied, the expiration date will default to null and never expire.
    token_force_regenerate       : (Optional) If set to `true`, a new token will be generated even if a token already exists. This will invalidate the existing token!
    visibility                   : (Optional) The visibility of the team (`secret` or `organization`).
  EOT
  type = list(object({
    name                          = string
    allow_member_token_management = optional(bool, true)
    organization_access = optional(object({
      access_secret_teams        = optional(bool, false)
      delegate_policy_overrides  = optional(bool, false)
      manage_agent_pools         = optional(bool, false)
      manage_membership          = optional(bool, false)
      manage_modules             = optional(bool, false)
      manage_organization_access = optional(bool, false)
      manage_policies            = optional(bool, false)
      manage_policy_overrides    = optional(bool, false)
      manage_projects            = optional(bool, false)
      manage_providers           = optional(bool, false)
      manage_run_tasks           = optional(bool, false)
      manage_teams               = optional(bool, false)
      manage_vcs_settings        = optional(bool, false)
      manage_workspaces          = optional(bool, false)
      read_projects              = optional(bool, false)
      read_workspaces            = optional(bool, false)
    }), null)
    sso_team_id            = optional(string)
    token                  = optional(bool, false)
    token_description      = optional(string)
    token_expired_at       = optional(string)
    token_force_regenerate = optional(bool, false)
    visibility             = optional(string, "organization")
  }))
  nullable = false
  default  = []

  validation {
    condition     = length([for team in var.teams : team.organization_access != null ? team.organization_access.read_projects != false && team.organization_access.manage_projects != false ? false : true : true]) == length(var.teams)
    error_message = "Project access must be `read` or `manage`."
  }

  validation {
    condition     = length([for team in var.teams : team.organization_access != null ? team.organization_access.read_workspaces != false && team.organization_access.manage_workspaces != false ? false : true : true]) == length(var.teams)
    error_message = "Workspaces access must be `read` or `manage`."
  }

  validation {
    condition     = length([for team in var.teams : team.organization_access != null ? team.organization_access.manage_projects == true && team.organization_access.manage_workspaces != true ? false : true : true]) == length(var.teams)
    error_message = "`manage_projects` requires `manage_workspaces` to be set to `true`."
  }
  validation {
    condition     = length([for team in var.teams : team.token_expired_at != null ? length(regexall("^((?:(\\d{4}-\\d{2}-\\d{2})T(\\d{2}:\\d{2}:\\d{2}))Z)$", team.token_expired_at)) > 0 ? true : false : true]) == length(var.teams)
    error_message = "The expiration date must be a date/time string in RFC3339 format (e.g., '2024-12-31T23:59:59Z')."
  }
  validation {
    condition     = length([for team in var.teams : contains(["secret", "organization"], team.visibility)]) == length(var.teams)
    error_message = "Valid values for `visibility` is \"secret\" or \"organization\"."
  }
}

variable "user_token_max_ttl" {
  description = "(Optional) Maximum lifespan allowed for user tokens to access the organization's resources. Format is <number><unit> (e.g., '0.5h', '3w', '6mo', '2y'). Defaults to null."
  type        = string
  nullable    = true
  default     = null
}

variable "user_tokens_enabled" {
  description = "(Optional) Whether user tokens can be used to read or update the organization."
  type        = bool
  default     = true
}

variable "workspaces_factory_agent_pool_id" {
  description = "(Optional) The ID of an agent pool to assign to the workspace for the `workspaces factory`. Requires `execution_mode` to be set to `agent`. This value must not be provided if `execution_mode` is set to any other value."
  type        = string
  nullable    = true
  default     = null
}

variable "workspaces_factory_description" {
  description = "(Optional) A description for the workspace for the `workspaces factory`."
  type        = string
  nullable    = true
  default     = "Code to provision and manage HCP Terraform workspaces using Terraform code (IaC)."
}

variable "workspaces_factory_execution_mode" {
  description = "(Optional) Which execution mode to use for the `workspaces factory`. Using Terraform Cloud, valid values are `remote`, `local` or `agent`. When set to `local`, the workspace will be used for state storage only. Important: If you omit this attribute, the resource configures the workspace to use your organization's default execution mode (which in turn defaults to `remote`), removing any explicit value that might have previously been set for the workspace."
  type        = string
  nullable    = true
  default     = null

  validation {
    condition     = var.workspaces_factory_execution_mode != null ? contains(["null", "remote", "local", "agent"], var.workspaces_factory_execution_mode) ? true : false : true
    error_message = "Valid values are \"remote\", \"local\" or \"agent\"."
  }
}

variable "workspaces_factory_github_teams" {
  description = <<EOT
  (Optional) The workspaces_factory_github_teams block supports the following:
    name        : (Required) The name of the team.
    description : (Optional) A description of the team.
    permission  : (Optional) The permissions of team members regarding the repository. Must be one of `pull`, `triage`, `push`, `maintain`, `admin` or the name of an existing custom repository role within the organisation.
  EOT
  type = list(object({
    name        = string
    description = optional(string)
    permission  = optional(string, "pull")
  }))
  nullable = false
  default = [{
    name        = "HCPTerraform-workspacesFactory-Contributors"
    description = "This group grant write access to the HCP Terraform workspaces repository."
    permission  = "push"
  }]
}

variable "workspaces_factory_tag" {
  description = "(Optional) A map of key value tags for this workspace for the `workspaces factory`."
  type        = map(string)
  nullable    = true
  default     = null
}

variable "workspaces_factory_workspace_name" {
  description = "(Optional) Name of the workspace for the `workspaces factory`."
  type        = string
  nullable    = true
  default     = "HCPTerraform-WorkspacesFactory"
}
