resource "github_repository" "this" {

  name                                    = var.name
  description                             = var.description
  homepage_url                            = var.homepage_url
  visibility                              = var.visibility
  has_issues                              = var.has_issues
  has_discussions                         = var.has_discussions
  has_projects                            = var.has_projects
  has_wiki                                = var.has_wiki
  is_template                             = var.is_template
  allow_merge_commit                      = var.allow_merge_commit
  allow_squash_merge                      = var.allow_squash_merge
  allow_rebase_merge                      = var.allow_rebase_merge
  allow_auto_merge                        = var.allow_auto_merge
  squash_merge_commit_title               = var.squash_merge_commit_title
  squash_merge_commit_message             = var.squash_merge_commit_message
  merge_commit_title                      = var.merge_commit_title
  merge_commit_message                    = var.merge_commit_message
  delete_branch_on_merge                  = var.delete_branch_on_merge
  auto_init                               = var.auto_init
  gitignore_template                      = var.gitignore_template
  license_template                        = var.license_template
  archived                                = var.archived
  archive_on_destroy                      = var.archive_on_destroy
  topics                                  = var.topics
  vulnerability_alerts                    = var.vulnerability_alerts
  ignore_vulnerability_alerts_during_read = var.ignore_vulnerability_alerts_during_read
  allow_update_branch                     = var.allow_update_branch

  dynamic "pages" {
    for_each = var.pages != null ? [true] : []
    content {
      dynamic "source" {
        for_each = var.pages.source != null ? [true] : []
        content {
          branch = var.pages.source.branch
          path   = var.pages.source.path
        }
      }
      build_type = var.pages.build_type
      cname      = var.pages.cname
    }
  }

  dynamic "security_and_analysis" {
    for_each = var.security_and_analysis != null ? [true] : []
    content {
      dynamic "advanced_security" {
        for_each = var.security_and_analysis.advanced_security != null ? [true] : []
        content {
          status = var.security_and_analysis.advanced_security.status
        }
      }
      dynamic "secret_scanning" {
        for_each = var.security_and_analysis.secret_scanning != null ? [true] : []
        content {
          status = var.security_and_analysis.secret_scanning.status
        }
      }
      dynamic "secret_scanning_push_protection" {
        for_each = var.security_and_analysis.secret_scanning_push_protection != null ? [true] : []
        content {
          status = var.security_and_analysis.secret_scanning_push_protection.status
        }
      }
    }
  }

  dynamic "template" {
    for_each = var.template != null ? [true] : []
    content {
      owner                = var.template.owner
      repository           = var.template.repository
      include_all_branches = var.template.include_all_branches
    }
  }

  lifecycle {
    precondition {
      condition     = var.security_and_analysis != null ? var.visibility == "public" ? var.security_and_analysis.advanced_security == null ? true : false : true : true
      error_message = "`advanced_security` is always available for public repos."
    }
  }

}

resource "github_branch_protection" "this" {
  for_each                        = { for branch_protection in var.branch_protections : branch_protection.pattern => branch_protection }
  repository_id                   = github_repository.this.name
  pattern                         = each.value.pattern
  enforce_admins                  = each.value.enforce_admins
  require_signed_commits          = each.value.require_signed_commits
  required_linear_history         = each.value.required_linear_history
  require_conversation_resolution = each.value.require_conversation_resolution

  dynamic "required_status_checks" {
    for_each = each.value.required_status_checks != null ? [true] : []
    content {
      strict   = each.value.required_status_checks.strict
      contexts = each.value.required_status_checks.contexts
    }
  }

  dynamic "required_pull_request_reviews" {
    for_each = each.value.required_pull_request_reviews != null ? [true] : []
    content {
      dismiss_stale_reviews           = each.value.required_pull_request_reviews.dismiss_stale_reviews
      restrict_dismissals             = each.value.required_pull_request_reviews.restrict_dismissals
      dismissal_restrictions          = each.value.required_pull_request_reviews.dismissal_restrictions
      pull_request_bypassers          = each.value.required_pull_request_reviews.pull_request_bypassers
      require_code_owner_reviews      = each.value.required_pull_request_reviews.require_code_owner_reviews
      required_approving_review_count = each.value.required_pull_request_reviews.required_approving_review_count
      require_last_push_approval      = each.value.required_pull_request_reviews.require_last_push_approval
    }
  }

  dynamic "restrict_pushes" {
    for_each = each.value.restrict_pushes != null ? [true] : []
    content {
      blocks_creations = each.value.blocks_creations
      push_allowances  = each.value.push_allowances
    }
  }

  force_push_bypassers = each.value.force_push_bypassers
  allows_deletions     = each.value.allows_deletions
  allows_force_pushes  = each.value.allows_force_pushes
  lock_branch          = each.value.lock_branch
}
