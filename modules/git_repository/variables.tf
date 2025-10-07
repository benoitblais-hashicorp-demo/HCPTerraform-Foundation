# The following variables are used to create and manage repository (github_repository).

variable "name" {
  description = "(Required) The name of the repository."
  type        = string
}

variable "description" {
  description = "(Optional) A description of the repository."
  type        = string
  default     = null
}

variable "homepage_url" {
  description = "(Optional) URL of a page describing the project."
  type        = string
  default     = null
}

variable "visibility" {
  description = "(Optional) Can be public or private. If your organization is associated with an enterprise account using GitHub Enterprise Cloud or GitHub Enterprise Server 2.20+, visibility can also be internal."
  type        = string
  default     = "public"

  validation {
    condition     = var.visibility != null ? contains(["public", "private", "internal"], var.visibility) ? true : false : false
    error_message = "Valid values are \"public\", \"private\" or \"internal\"."
  }
}

variable "has_issues" {
  description = "(Optional) Set to true to enable the GitHub Issues features on the repository."
  type        = bool
  default     = true
}

variable "has_discussions" {
  description = "(Optional) Set to true to enable GitHub Discussions on the repository."
  type        = bool
  default     = false
}

variable "has_projects" {
  description = "(Optional) Set to true to enable the GitHub Projects features on the repository. Per the GitHub documentation when in an organization that has disabled repository projects it will default to false and will otherwise default to true. If you specify true when it has been disabled it will return an error."
  type        = bool
  default     = true
}

variable "has_wiki" {
  description = "(Optional) Set to true to enable the GitHub Wiki features on the repository."
  type        = bool
  default     = true
}

variable "is_template" {
  description = "(Optional) Set to true to tell GitHub that this is a template repository."
  type        = bool
  default     = false
}

variable "allow_merge_commit" {
  description = "(Optional) Set to false to disable merge commits on the repository."
  type        = bool
  default     = true
}

variable "allow_squash_merge" {
  description = "(Optional) Set to false to disable squash merges on the repository."
  type        = bool
  default     = true
}

variable "allow_rebase_merge" {
  description = "(Optional) Set to false to disable rebase merges on the repository."
  type        = bool
  default     = true
}

variable "allow_auto_merge" {
  description = "(Optional) Set to true to allow auto-merging pull requests on the repository."
  type        = bool
  default     = false
}

variable "squash_merge_commit_title" {
  description = "(Optional) Can be PR_TITLE or COMMIT_OR_PR_TITLE for a default squash merge commit title. Applicable only if allow_squash_merge is true."
  type        = string
  default     = "COMMIT_OR_PR_TITLE"

  validation {
    condition     = var.squash_merge_commit_title != null ? contains(["PR_TITLE", "COMMIT_OR_PR_TITLE"], var.squash_merge_commit_title) ? true : false : false
    error_message = "Valid values are \"PR_TITLE\" or \"COMMIT_OR_PR_TITLE\"."
  }
}

variable "squash_merge_commit_message" {
  description = "(Optional) Can be PR_BODY, COMMIT_MESSAGES, or BLANK for a default squash merge commit message. Applicable only if allow_squash_merge is true."
  type        = string
  default     = "COMMIT_MESSAGES"

  validation {
    condition     = var.squash_merge_commit_message != null ? contains(["PR_BODY", "COMMIT_MESSAGES", "BLANK"], var.squash_merge_commit_message) ? true : false : false
    error_message = "Valid values are \"PR_BODY\", \"COMMIT_MESSAGES\" or \"BLANK\"."
  }
}

variable "merge_commit_title" {
  description = "Can be PR_TITLE or MERGE_MESSAGE for a default merge commit title. Applicable only if allow_merge_commit is true."
  type        = string
  default     = "MERGE_MESSAGE"

  validation {
    condition     = var.merge_commit_title != null ? contains(["PR_TITLE", "MERGE_MESSAGE"], var.merge_commit_title) ? true : false : false
    error_message = "Valid values are \"PR_TITLE\" or \"MERGE_MESSAGE\"."
  }
}

variable "merge_commit_message" {
  description = "Can be PR_BODY, PR_TITLE, or BLANK for a default merge commit message. Applicable only if allow_merge_commit is true."
  type        = string
  default     = "PR_TITLE"

  validation {
    condition     = var.merge_commit_message != null ? contains(["PR_BODY", "PR_TITLE", "BLANK"], var.merge_commit_message) ? true : false : false
    error_message = "Valid values are \"PR_BODY\", \"PR_TITLE\" or \"BLANK\"."
  }
}

variable "delete_branch_on_merge" {
  description = "(Optional) Automatically delete head branch after a pull request is merged."
  type        = bool
  default     = true
}

variable "auto_init" {
  description = "(Optional) Set to true to produce an initial commit in the repository."
  type        = bool
  default     = true
}

variable "gitignore_template" {
  description = "(Optional) Use the name of the template without the extension. For example, \"Haskell\"."
  type        = string
  default     = null
}

variable "license_template" {
  description = "(Optional) Use the name of the template without the extension. For example, \"mit\" or \"mpl-2.0\"."
  type        = string
  default     = null
}

variable "archived" {
  description = "(Optional) Specifies if the repository should be archived. NOTE Currently, the API does not support unarchiving."
  type        = bool
  default     = false
}

variable "archive_on_destroy" {
  description = "(Optional) Set to true to archive the repository instead of deleting on destroy."
  type        = bool
  default     = false
}

variable "pages" {
  description = <<EOT
  (Optional) The pages block supports the following:
    source     : (Optional) The source block supports the following:
      branch   : (Required) The repository branch used to publish the site's source files. (i.e. main or gh-pages.
      path     : (Optional) The repository directory from which the site publishes (Default: /).
    build_type : (Optional) The type of GitHub Pages site to build. Can be legacy or workflow. If you use legacy as build type you need to set the option source.
    cname      : (Optional) The custom domain for the repository. This can only be set after the repository has been created.
  EOT
  type = object({
    source = optional(object({
      branch = string
      path   = optional(string, "/")
    }))
    build_type = optional(string, null)
    cname      = optional(string, null)
  })
  default = null

  validation {
    condition     = var.pages != null ? var.pages.build_type != null ? contains(["legacy", "workflow"], var.pages.build_type) ? true : false : false : true
    error_message = "Valid values are \"legacy\" or \"workflow\"."
  }
}

variable "security_and_analysis" {
  description = <<EOT
  (Optional) The security_and_analysis block supports the following:
    advanced_security               : (Optional) The advanced_security block supports the following:
      status                        : (Required) Set to enabled to enable advanced security features on the repository. Can be enabled or disabled.
    secret_scanning                 : (Optional) The secret_scanning block supports the following:
      status                        : (Required) Set to enabled to enable secret scanning on the repository. Can be enabled or disabled. If set to enabled, the repository's visibility must be public or security_and_analysis[0].advanced_security[0].status must also be set to enabled.
    secret_scanning_push_protection : (Optional) The secret_scanning block supports the following:
      status                        : (Required) Set to enabled to enable secret scanning push protection on the repository. Can be enabled or disabled. If set to enabled, the repository's visibility must be public or security_and_analysis[0].advanced_security[0].status must also be set to enabled.
  EOT
  type = object({
    advanced_security = optional(object({
      status = string
    }), null)
    secret_scanning = optional(object({
      status = string
    }), null)
    secret_scanning_push_protection = optional(object({
      status = string
    }), null)
  })
  default = {
    secret_scanning = {
      status = "enabled"
    }
    secret_scanning_push_protection = {
      status = "enabled"
    }
  }

  validation {
    condition     = var.security_and_analysis != null ? var.security_and_analysis.advanced_security != null ? var.security_and_analysis.advanced_security.status != null ? contains(["enabled", "disabled"], var.security_and_analysis.advanced_security.status) ? true : false : false : true : true
    error_message = "Valid values are \"enabled\" or \"disabled\"."
  }
  validation {
    condition     = var.security_and_analysis != null ? var.security_and_analysis.secret_scanning != null ? var.security_and_analysis.secret_scanning.status != null ? contains(["enabled", "disabled"], var.security_and_analysis.secret_scanning.status) ? true : false : false : true : true
    error_message = "Valid values are \"enabled\" or \"disabled\"."
  }
  validation {
    condition     = var.security_and_analysis != null ? var.security_and_analysis.secret_scanning_push_protection != null ? var.security_and_analysis.secret_scanning_push_protection.status != null ? contains(["enabled", "disabled"], var.security_and_analysis.secret_scanning_push_protection.status) ? true : false : false : true : true
    error_message = "Valid values are \"enabled\" or \"disabled\"."
  }
}

variable "topics" {
  description = "(Optional) The list of topics of the repository."
  type        = list(string)
  default     = null
}

variable "template" {
  description = <<EOT
  (Optional) The template block supports the following:
    owner                : (Required) The GitHub organization or user the template repository is owned by.
    repository           : (Required) The name of the template repository.
    include_all_branches : (Optional) Whether the new repository should include all the branches from the template repository (defaults to false, which includes only the default branch from the template).
  EOT
  type = object({
    owner                = string
    repository           = string
    include_all_branches = optional(bool, false)
  })
  default = null
}

variable "vulnerability_alerts" {
  description = "(Optional) Set to true to enable security alerts for vulnerable dependencies. Enabling requires alerts to be enabled on the owner level. (Note for importing: GitHub enables the alerts on public repos but disables them on private repos by default.) See GitHub Documentation for details. Note that vulnerability alerts have not been successfully tested on any GitHub Enterprise instance and may be unavailable in those settings."
  type        = bool
  default     = true
}

variable "ignore_vulnerability_alerts_during_read" {
  description = "(Optional) Set to true to not call the vulnerability alerts endpoint so the resource can also be used without admin permissions during read."
  type        = bool
  default     = false
}

variable "allow_update_branch" {
  description = "(Optional) Set to true to always suggest updating pull request branches."
  type        = bool
  default     = false
}

# The following variable is used to configure branch protection for repository. (github_branch_protection).

variable "branch_protections" {
  description = <<EOT
    pattern                           : (Required) Identifies the protection rule pattern.
    enforce_admins                    : (Optional) Boolean, setting this to true enforces status checks for repository administrators.
    require_signed_commits            : (Optional) Boolean, setting this to true requires all commits to be signed with GPG.
    required_linear_history           : (Optional) Boolean, setting this to true enforces a linear commit Git history, which prevents anyone from pushing merge commits to a branch.
    require_conversation_resolution   : (Optional) Boolean, setting this to true requires all conversations on code must be resolved before a pull request can be merged.
    required_status_checks            : (Optional) The required_status_checks block supports the following:
      strict                          : (Optional) Require branches to be up to date before merging.
      contexts                        : (Optional) The list of status checks to require in order to merge into this branch. No status checks are required by default.
    required_pull_request_reviews     : (Optional) The required_pull_request_reviews block supports the following:
      dismiss_stale_reviews           : (Optional) Dismiss approved reviews automatically when a new commit is pushed.
      restrict_dismissals             : (Optional) Restrict pull request review dismissals.
      dismissal_restrictions          : (Optional) The list of actor Names/IDs with dismissal access. If not empty, restrict_dismissals is ignored. Actor names must either begin with a \"/\" for users or the organization name followed by a \"/\" for teams.
      pull_request_bypassers          : (Optional) The list of actor Names/IDs that are allowed to bypass pull request requirements. Actor names must either begin with a \"/\" for users or the organization name followed by a \"/\" for teams.
      require_code_owner_reviews      : (Optional) Require an approved review in pull requests including files with a designated code owner.
      required_approving_review_count : (Optional) Require x number of approvals to satisfy branch protection requirements. If this is specified it must be a number between 0-6.
      require_last_push_approval      : (Optional) Require that The most recent push must be approved by someone other than the last pusher.
    restrict_pushes                   : (Optional) The restrict_pushes block supports the following:
      blocks_creations                : (Optional) Optional) Boolean, setting this to `false` allows people, teams, or apps to create new branches matching this rule.
      push_allowances                 : (Optional) The list of actor Names/IDs that may push to the branch. Actor names must either begin with a \"/\" for users or the organization name followed by a \"/\" for teams.
    force_push_bypassers              : (Optional) The list of actor Names/IDs that are allowed to bypass force push restrictions. Actor names must either begin with a \"/\" for users or the organization name followed by a \"/\" for teams.
    allows_deletions                  : (Optional) Boolean, setting this to true to allow the branch to be deleted.
    allows_force_pushes               : (Optional) Boolean, setting this to true to allow force pushes on the branch.
    lock_branch                       : (Optional) Boolean, Setting this to true will make the branch read-only and preventing any pushes to it.
  EOT
  type = list(object({
    pattern                         = string
    enforce_admins                  = optional(bool, false)
    require_signed_commits          = optional(bool, false)
    required_linear_history         = optional(bool, false)
    require_conversation_resolution = optional(bool, false)
    required_status_checks = optional(object({
      strict   = optional(bool, false)
      contexts = optional(list(string), [])
    }), null)
    required_pull_request_reviews = optional(object({
      dismiss_stale_reviews           = optional(bool, false)
      restrict_dismissals             = optional(bool, false)
      dismissal_restrictions          = optional(list(string), [])
      pull_request_bypassers          = optional(list(string), [])
      require_code_owner_reviews      = optional(bool, false)
      required_approving_review_count = optional(string, null)
      require_last_push_approval      = optional(bool, false)
    }), null)
    restrict_pushes = optional(object({
      blocks_creations = optional(bool, false)
      push_allowances  = optional(list(string), [])
    }))
    force_push_bypassers = optional(list(string), [])
    allows_deletions     = optional(bool, false)
    allows_force_pushes  = optional(bool, false)
    lock_branch          = optional(bool, false)
  }))
  default = [
    {
      pattern                         = "main"
      enforce_admins                  = true
      require_signed_commits          = false
      required_linear_history         = false
      require_conversation_resolution = true
      required_status_checks          = null
      required_pull_request_reviews = {
        dismiss_stale_reviews           = true
        restrict_dismissals             = null
        dismissal_restrictions          = null
        pull_request_bypassers          = null
        require_code_owner_reviews      = true
        required_approving_review_count = "0"
        require_last_push_approval      = false
      }
      push_restrictions    = null
      force_push_bypassers = null
      allows_deletions     = false
      allows_force_pushes  = false
      blocks_creations     = false
      lock_branch          = false
    }
  ]
}
