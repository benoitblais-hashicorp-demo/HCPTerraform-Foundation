resource "github_team" "this" {
  name                      = var.name
  create_default_maintainer = var.create_default_maintainer
  description               = var.description
  ldap_dn                   = var.ldap_dn
  parent_team_id            = var.parent_team_id
  privacy                   = var.privacy
}

resource "github_team_repository" "this" {
  count      = var.repository != null ? 1 : 0
  repository = var.repository
  team_id    = github_team.this.id
  permission = var.permission
}