variable "name" {
  description = "(Required) Name of the team."
  type        = string
}

variable "organization" {
  description = "(Required) Name of the organization. If omitted, organization must be defined in the provider config."
  type        = string
}

variable "allow_member_token_management" {
  description = "(Optional) Whether team members can manage team tokens. Used by Owners and users with Manage Teams permissions. Defaults to `true`."
  type        = bool
  default     = true
}

variable "custom_project_access" {
  description = <<EOT
  (Optional) Settings for the team's project access.
    settings      : (Optional) The permission to grant for the project's settings. Valid strings: `read`, `update`, or `delete`.
    teams         : (Optional) The permission to grant for the project's teams. Valid strings: `none`, `read`, or `manage`.
    variable_sets : (Optional) The permission to grant for the project's variable sets. Valid strings: `none`, `read`, or `write`.
  EOT
  type = object({
    settings      = optional(string, "read")
    teams         = optional(string, "none")
    variable_sets = optional(string, "none")
  })
  default = null

  validation {
    condition     = var.custom_project_access != null ? contains(["read", "update", "delete"], var.custom_project_access.settings) ? true : false : true
    error_message = "Valid strings: `read`, `update`, or `delete`."
  }

  validation {
    condition     = var.custom_project_access != null ? contains(["none", "read", "manage"], var.custom_project_access.teams) ? true : false : true
    error_message = "Valid strings: `none`, `read`, or `manage`."
  }

  validation {
    condition     = var.custom_project_access != null ? contains(["none", "read", "write"], var.custom_project_access.variable_sets) ? true : false : true
    error_message = "Valid strings: `none`, `read`, or `write`."
  }
}

variable "custom_workspace_access" {
  description = <<EOT
    runs             : (Optional) The permission to grant project's workspaces' runs. Valid strings: `read`, `plan`, or `apply`.
    sentinel_mocks   : (Optional) The permission to grant project's workspaces' Sentinel mocks. Valid strings: `none`, or `read`.
    state_versions   : (Optional) The permission to grant project's workspaces' state versions. Valid strings: `none`, `read-outputs`, `read`, or `write`.
    variables        : (Optional) The permission to grant project's workspaces' variables. Valid strings: `none`, `read`, or `write`.
    create           : (Optional) The permission to create project's workspaces in the project.
    locking          : (Optional) The permission to manually lock or unlock the project's workspaces.
    delete           : (Optional) The permission to delete the project's workspaces.
    move             : (Optional) This permission to move workspaces into and out of the project. The team must also have permissions to the project(s) receiving the the workspace(s).
    policy_overrides : (Optional) Allows a team to override soft-mandatory policy evaluations, provided that team has been granted the org level delegate policy overrides permission.
    run_tasks        : (Optional) The permission to manage run tasks within the project's workspaces.
  EOT
  type = object({
    runs             = optional(string, "read")
    sentinel_mocks   = optional(string, "none")
    state_versions   = optional(string, "none")
    variables        = optional(string, "none")
    create           = optional(bool, false)
    locking          = optional(bool, false)
    delete           = optional(bool, false)
    move             = optional(bool, false)
    policy_overrides = optional(bool, false)
    run_tasks        = optional(bool, false)
  })
  default = null

  validation {
    condition     = var.custom_workspace_access != null ? contains(["read", "plan", "apply"], var.custom_workspace_access.runs) ? true : false : true
    error_message = "Valid strings: `read`, `plan`, or `apply`."
  }

  validation {
    condition     = var.custom_workspace_access != null ? contains(["none", "read"], var.custom_workspace_access.sentinel_mocks) ? true : false : true
    error_message = "Valid strings: `none`, or `read`."
  }

  validation {
    condition     = var.custom_workspace_access != null ? contains(["none", "read-outputs", "read", "write"], var.custom_workspace_access.state_versions) ? true : false : true
    error_message = "Valid strings: `none`, `read-outputs`, `read`, or `write`."
  }

  validation {
    condition     = var.custom_workspace_access != null ? contains(["none", "read", "write"], var.custom_workspace_access.variables) ? true : false : true
    error_message = "Valid strings: `none`, `read`, or `write`."
  }
}

variable "notification_configurations" {
  description = <<EOT
  (Optional) A list of notification configurations for the team. A team can have up to 20 notification configurations.
    name             : (Required) Name of the team notification configuration. Must be unique within the list.
    destination_type : (Required) The type of notification configuration payload to send. Valid values are `generic`, `email`, `slack`, and `microsoft-teams`.
    email_addresses  : (Optional) (Terraform Enterprise only) A list of email addresses. This value must not be provided if `destination_type` is `generic`, `microsoft-teams`, or `slack`.
    email_user_ids   : (Optional) A list of user IDs. This value must not be provided if `destination_type` is `generic`, `microsoft-teams`, or `slack`.
    enabled          : (Optional) Whether the team notification configuration should be enabled or not. Disabled configurations will not send any notifications. Defaults to `false`.
    token            : (Optional) A secure token which can be used by the receiving server to verify request authenticity. Only valid when `destination_type` is `generic`. Cannot be used with `token_wo`.
    token_wo         : (Optional) Write-only alternative to `token`. Never stored in the Terraform state. Only valid when `destination_type` is `generic`. Cannot be used with `token`.
    token_wo_version : (Optional) Tracks the version of `token_wo`. Increment it to push a new `token_wo` value. Cannot be used with `token`.
    triggers         : (Optional) The list of triggers for which this notification configuration will send notifications. Currently, the only valid value is `change_request:created`.
    url              : (Optional) The HTTP or HTTPS URL where notification requests will be made. Required if `destination_type` is `generic`, `microsoft-teams`, or `slack`. Must not be provided if `destination_type` is `email`.
  EOT
  type = list(object({
    name             = string
    destination_type = string
    email_addresses  = optional(set(string))
    email_user_ids   = optional(set(string))
    enabled          = optional(bool, false)
    token            = optional(string)
    token_wo         = optional(string)
    token_wo_version = optional(number)
    triggers         = optional(set(string))
    url              = optional(string)
  }))
  sensitive = true
  nullable  = false
  default   = []

  validation {
    condition     = length([for config in var.notification_configurations : config.destination_type if contains(["generic", "email", "slack", "microsoft-teams"], config.destination_type)]) == length(var.notification_configurations)
    error_message = "Valid values for `destination_type` are \"generic\", \"email\", \"slack\", or \"microsoft-teams\"."
  }

  validation {
    condition     = length(distinct([for config in var.notification_configurations : config.name])) == length(var.notification_configurations)
    error_message = "Each notification configuration must have a unique `name`."
  }

  validation {
    condition     = length(var.notification_configurations) <= 20
    error_message = "A team can have up to 20 notification configurations."
  }
}

variable "organization_access" {
  description = <<EOT
  (Optional) Settings for the team's organization access.
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
  EOT
  type = object({
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
  })
  default = null

  validation {
    condition     = var.organization_access != null ? var.organization_access.read_projects != false && var.organization_access.manage_projects != false ? false : true : true
    error_message = "Project access must be `read` or `manage`."
  }

  validation {
    condition     = var.organization_access != null ? var.organization_access.read_workspaces != false && var.organization_access.manage_workspaces != false ? false : true : true
    error_message = "Workspaces access must be `read` or `manage`."
  }

  validation {
    condition     = var.organization_access != null ? var.organization_access.manage_projects == true && var.organization_access.manage_workspaces != true ? false : true : true
    error_message = "`manage_projects` requires `manage_workspaces` to be set to `true`."
  }
}

variable "organization_membership_ids" {
  description = "(Required) IDs of organization memberships to be added."
  type        = list(string)
  default     = []
}

variable "project_access" {
  description = "(Optional) Type of fixed access to grant. Valid values are `admin`, `maintain`, `write`, `read`, or `custom`."
  type        = string
  default     = "read"

  validation {
    condition     = var.project_access != null ? contains(["admin", "maintain", "write", "read", "custom"], var.project_access) ? true : false : true
    error_message = "Valid values are `admin`, `maintain`, `write`, `read`, or `custom`."
  }
}

variable "project_id" {
  description = "(Optional) ID of the project to which the team will be added."
  type        = string
  default     = null
}

variable "project_name" {
  description = "(Optional) Name of the project to which the team will be added."
  type        = string
  default     = null
}

variable "sso_team_id" {
  description = "(Optional) Unique Identifier to control team membership via SAML."
  type        = string
  default     = null
}

variable "token" {
  description = "(Optional) If set to `true`, a team token will be generated."
  type        = bool
  default     = false
}

variable "token_description" {
  description = "(Optional) The token's description, which must be unique per team. Required if creating multiple tokens for a single team."
  type        = string
  default     = null
}

variable "token_expired_at" {
  description = "(Optional) The token's expiration date. The expiration date must be a date/time string in RFC3339 format (e.g., '2024-12-31T23:59:59Z'). If no expiration date is supplied, the expiration date will default to null and never expire."
  type        = string
  default     = null

  validation {
    condition     = var.token_expired_at != null ? length(regexall("^((?:(\\d{4}-\\d{2}-\\d{2})T(\\d{2}:\\d{2}:\\d{2}))Z)$", var.token_expired_at)) > 0 ? true : false : true
    error_message = "The expiration date must be a date/time string in RFC3339 format (e.g., '2024-12-31T23:59:59Z')."
  }
}

variable "token_force_regenerate" {
  description = "(Optional) If set to `true`, a new token will be generated even if a token already exists. This will invalidate the existing token!"
  type        = bool
  default     = false
}

variable "visibility" {
  description = "(Optional) The visibility of the team (`secret` or `organization`)."
  type        = string
  default     = "organization"

  validation {
    condition     = var.visibility != null ? contains(["secret", "organization"], var.visibility) ? true : false : true
    error_message = "Valid values are `secret` or `organization`."
  }
}

variable "workspace_access" {
  description = "(Optional) Type of fixed access to grant. Valid values are `admin`, `read`, `plan`, or `write`. To use custom permissions, use a `workspace_permission` block instead."
  type        = string
  default     = null

  validation {
    condition     = var.workspace_access != null ? contains(["admin", "read", "plan", "write"], var.workspace_access) ? true : false : true
    error_message = "Valid values are `admin`, `read`, `plan`, or `write`."
  }
}

variable "workspace_id" {
  description = "(Optional) ID of the workspace to which the team will be added."
  type        = string
  default     = null
}

variable "workspace_permission" {
  description = <<EOT
  (Optional) Settings for the team's workspace access.
      runs              : (Optional) The permission to grant the team on the workspace's runs. Valid values are `read`, `plan`, or `apply`.
      variables         : (Optional) The permission to grant the team on the workspace's variables. Valid values are `none`, `read`, or `write`.
      state_versions    : (Optional) The permission to grant the team on the workspace's state versions. Valid values are `none`, `read`, `read-outputs`, or `write`.
      sentinel_mocks    : (Optional) The permission to grant the team on the workspace's generated Sentinel mocks, Valid values are `none` or `read`.
      workspace_locking : (Optional) Boolean determining whether or not to grant the team permission to manually lock/unlock the workspace.
      run_tasks         : (Optional) Boolean determining whether or not to grant the team permission to manage workspace run tasks.
      policy_overrides  : (Optional) Allows a team to override soft-mandatory policy evaluations, provided that team has been granted the org level 'delegate policy overrides' permission.
  EOT
  type = object({
    runs              = optional(string, "read")
    variables         = optional(string, "none")
    state_versions    = optional(string, "none")
    sentinel_mocks    = optional(string, "none")
    workspace_locking = optional(bool, false)
    run_tasks         = optional(bool, false)
    policy_overrides  = optional(bool, false)
  })
  default = null

  validation {
    condition     = var.workspace_permission != null ? contains(["read", "plan", "apply"], var.workspace_permission.runs) ? true : false : true
    error_message = "Valid strings: `read`, `plan`, or `apply`."
  }

  validation {
    condition     = var.workspace_permission != null ? contains(["none", "read", "write"], var.workspace_permission.variables) ? true : false : true
    error_message = "Valid strings: `none`, `read`, or `write`."
  }

  validation {
    condition     = var.workspace_permission != null ? contains(["none", "read", "read-outputs", "write"], var.workspace_permission.state_versions) ? true : false : true
    error_message = "Valid strings: `none`, `read`, `read-outputs`, or `write`."
  }

  validation {
    condition     = var.workspace_permission != null ? contains(["none", "read"], var.workspace_permission.sentinel_mocks) ? true : false : true
    error_message = "Valid strings: `none`, or `read`."
  }
}