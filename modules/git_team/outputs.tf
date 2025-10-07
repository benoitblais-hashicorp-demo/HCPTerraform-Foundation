output "id" {
  description = "The ID of the created team."
  value       = github_team.this.id
}

output "node_id" {
  description = "The Node ID of the created team."
  value       = github_team.this.node_id
}

output "slug" {
  description = "The slug of the created team, which may or may not differ from name, depending on whether name contains \"URL-unsafe\" characters. Useful when referencing the team in github_branch_protection."
  value       = github_team.this.slug
}

output "team" {
  description = "GitHub team resource."
  value       = github_team.this
}
