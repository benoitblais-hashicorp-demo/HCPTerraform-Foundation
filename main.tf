# The following code manage the organization settins.

resource "tfe_organization" "this" {
  email                                                   = var.organization_email
  name                                                    = var.organization_name
  aggregated_commit_status_enabled                        = var.aggregated_commit_status_enabled
  allow_force_delete_workspaces                           = var.allow_force_delete_workspaces
  assessments_enforced                                    = var.assessments_enforced
  collaborator_auth_policy                                = var.collaborator_auth_policy
  cost_estimation_enabled                                 = var.cost_estimation_enabled
  owners_team_saml_role_id                                = var.owners_team_saml_role_id
  send_passing_statuses_for_untriggered_speculative_plans = var.send_passing_statuses_for_untriggered_speculative_plans
  session_remember_minutes                                = var.session_remember_minutes
  session_timeout_minutes                                 = var.session_timeout_minutes
  speculative_plan_management_enabled                     = var.speculative_plan_management_enabled
}

# The following code block must be use to import de organization into terraform.  Once it's done, you can remove it.

# import {
#   id = ""
#   to = tfe_organization.this
# }

# The following code block is use to set the default execution mode of an organization. 

resource "tfe_organization_default_settings" "this" {
  # default_agent_pool_id  = var.default_agent_pool_id
  default_execution_mode = var.default_execution_mode
  organization           = tfe_organization.this.name

  # lifecycle {
  #   precondition {
  #     condition     = var.default_agent_pool_id != null ? var.default_execution_mode == "agent" ? true : false : true
  #     error_message = "Requires `default_execution_mode` to be set to \"agent\" if `default_agent_pool_id` is set."
  #   }
  # }
}

# The following code block is use to create and manage agent pools avaiable at the organization level.

module "agent_pool" {
  source            = "./modules/tfe_agent"
  for_each          = toset(var.agent_pools)
  name              = each.value
  organization      = tfe_organization.this.name
  token_description = ["token"]
}

# The following code block is use to create and manage team at the organization level.

module "teams" {
  source                 = "./modules/tfe_team"
  for_each               = nonsensitive({ for team in var.teams : team.name => team })
  name                   = each.value.name
  organization           = tfe_organization.this.name
  organization_access    = try(each.value.organization_access, null)
  sso_team_id            = try(each.value.sso_team_id, null)
  token                  = try(each.value.token, false)
  token_expired_at       = try(each.value.token_expired_at, null)
  token_force_regenerate = try(each.value.token_force_regenerate, null)
  visibility             = try(each.value.visibility, "organization")
}

# The following code block is use to create and manage the project where all the workspaces related to the foundation will be stored.

resource "tfe_project" "hcp_foundation" {
  count        = var.hcp_foundation_project_name != null ? 1 : 0
  name         = var.hcp_foundation_project_name
  organization = tfe_organization.this.name
  description  = var.hcp_foundation_project_description
  tags = merge(var.hcp_foundation_project_tags, {
    managed_by_terraform = "true"
  })
}

# *********************************************************************************************** #
#                                       Policies Factory                                          #
# *********************************************************************************************** #

# The following module block is used to create and manage the workspace used by the `policies factory`.

module "policies_factory_workspace" {
  source         = "./modules/tfe_workspace"
  count          = var.policies_factory_workspace_name != null ? 1 : 0
  name           = var.policies_factory_workspace_name
  agent_pool_id  = var.policies_factory_agent_pool_id
  description    = var.policies_factory_description
  execution_mode = var.policies_factory_execution_mode
  organization   = tfe_organization.this.name
  project_id     = length(tfe_project.hcp_foundation) > 0 ? tfe_project.hcp_foundation[0].id : null
  tags           = merge(var.policies_factory_tag, { managed_by_terraform = true })
}

# The following module blocks are used to create and manage the HCP Terraform teams required by the `policies factory`.

module "policies_factory_team_hcp" {
  source       = "./modules/tfe_team"
  count        = length(module.policies_factory_workspace) > 0 != null ? 1 : 0
  name         = lower(replace("${module.policies_factory_workspace[0].workspace.name}-hcp", "/\\W|_|\\s/", "-"))
  organization = tfe_organization.this.name
  organization_access = {
    manage_policies = true
  }
  token = true
}

module "policies_factory_team_git" {
  source       = "./modules/tfe_team"
  count        = length(module.policies_factory_workspace) > 0 != null ? 1 : 0
  name         = lower(replace("${module.policies_factory_workspace[0].workspace.name}-git", "/\\W|_|\\s/", "-"))
  organization = tfe_organization.this.name
  token        = true
  workspace_id = module.policies_factory_workspace[0].id
  workspace_permission = {
    runs = "apply"
  }
}

# The following resource block is used to create and manage the environment variable required at the workspace level to get authenticated into HCP Terraform by the workspace.

resource "tfe_variable" "policies_factory" {
  count        = length(module.policies_factory_team_hcp) > 0 ? 1 : 0
  key          = "TFE_TOKEN"
  value        = module.policies_factory_team_hcp[0].token
  category     = "env"
  sensitive    = true
  workspace_id = module.policies_factory_workspace[0].id
}

# The following module block is used to create and manage the GitHub repository used by the `policies factory`.

module "policies_factory_repository" {
  source      = "./modules/git_repository"
  count       = length(module.policies_factory_workspace) > 0 != null ? 1 : 0
  name        = module.policies_factory_workspace[0].workspace.name
  description = module.policies_factory_workspace[0].workspace.description
  topics      = ["factory", "terraform-workspace", "terraform", "terraform-managed"]
}

# The following resource block is used to create and manage an action secret at the repository level for the `policies factory`.

resource "github_actions_secret" "policies_factory" {
  count           = length(module.policies_factory_repository) > 0 ? 1 : 0
  repository      = module.policies_factory_repository[0].repository.name
  secret_name     = "TFE_TOKEN"
  plaintext_value = module.policies_factory_team_git[0].token
}

# The following module block is used to create and manage a GitHub team for the `policies factory`.

module "policies_factory_git_teams" {
  for_each    = { for team in var.policies_factory_github_teams : team.name => team }
  source      = "./modules/git_team"
  name        = each.value.name
  description = try(each.value.description, null)
  permission  = try(each.value.permission, null)
  repository  = module.policies_factory_repository[0].repository.name
}

# *********************************************************************************************** #
#                                        Modules Factory                                          #
# *********************************************************************************************** #

# The following module block is used to create and manage the workspace used by the `modules factory`.

module "modules_factory_workspace" {
  source         = "./modules/tfe_workspace"
  count          = var.modules_factory_workspace_name != null ? 1 : 0
  name           = var.modules_factory_workspace_name
  agent_pool_id  = var.modules_factory_agent_pool_id
  description    = var.modules_factory_description
  execution_mode = var.modules_factory_execution_mode
  organization   = tfe_organization.this.name
  project_id     = length(tfe_project.hcp_foundation) > 0 ? tfe_project.hcp_foundation[0].id : null
  tags           = merge(var.modules_factory_tag, { managed_by_terraform = true })
}

# The following module blocks are used to create and manage the HCP Terraform teams required by the `modules factory`.

module "modules_factory_team_hcp" {
  source       = "./modules/tfe_team"
  count        = length(module.modules_factory_workspace) > 0 != null ? 1 : 0
  name         = lower(replace("${module.modules_factory_workspace[0].workspace.name}-hcp", "/\\W|_|\\s/", "-"))
  organization = tfe_organization.this.name
  organization_access = {
    manage_membership          = true
    manage_modules             = true
    manage_organization_access = true
    manage_projects            = true
    manage_teams               = true
    manage_workspaces          = true
  }
  token = true
}

module "modules_factory_team_git" {
  source       = "./modules/tfe_team"
  count        = length(module.modules_factory_workspace) > 0 != null ? 1 : 0
  name         = lower(replace("${module.modules_factory_workspace[0].workspace.name}-git", "/\\W|_|\\s/", "-"))
  organization = tfe_organization.this.name
  organization_access = {
    manage_projects            = true   # This is required to be able to create workspace from no-code module through GitHub Actions.
    manage_workspaces          = true   # This is required to be able to create workspace from no-code module through GitHub Actions.
  }
  token        = true
  workspace_id = module.modules_factory_workspace[0].id
  workspace_permission = {
    runs = "apply"
  }
}

# The following resource block is used to create and manage the environment variable required at the workspace level to get authenticated into HCP Terraform by the workspace.

resource "tfe_variable" "modules_factory" {
  count        = length(module.modules_factory_team_hcp) > 0 ? 1 : 0
  key          = "TFE_TOKEN"
  value        = module.modules_factory_team_hcp[0].token
  category     = "env"
  sensitive    = true
  workspace_id = module.modules_factory_workspace[0].id
}

# The following module block is used to create and manage the GitHub repository used by the `modules factory`.

module "modules_factory_repository" {
  source      = "./modules/git_repository"
  count       = length(module.modules_factory_workspace) > 0 != null ? 1 : 0
  name        = module.modules_factory_workspace[0].workspace.name
  description = module.modules_factory_workspace[0].workspace.description
  topics      = ["factory", "terraform-workspace", "terraform", "terraform-managed"]
}

# The following resource block is used to create and manage an action secret at the repository level for the `modules factory`.

resource "github_actions_secret" "modules_factory" {
  count           = length(module.modules_factory_repository) > 0 ? 1 : 0
  repository      = module.modules_factory_repository[0].repository.name
  secret_name     = "TFE_TOKEN"
  plaintext_value = module.modules_factory_team_git[0].token
}

# The following module block is used to create and manage a GitHub team for the `modules factory`.

module "modules_factory_git_teams" {
  for_each    = { for team in var.modules_factory_github_teams : team.name => team }
  source      = "./modules/git_team"
  name        = each.value.name
  description = try(each.value.description, null)
  permission  = try(each.value.permission, null)
  repository  = module.modules_factory_repository[0].repository.name
}
