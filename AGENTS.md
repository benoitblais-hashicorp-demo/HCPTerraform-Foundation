# AGENTS.md for Terraform Project

This file provides instructions for AI coding agents working on this Terraform Project.

## Project Overview

This project provides the foundational configuration and life-cycle management of all HCP Terraform foundation elements for the organization. It uses the `hashicorp/tfe` provider to manage resources like projects, workspaces, teams, variable sets, and variables.

## Module and Repository Structure

Organize your Terraform project as follows:

```text
├── .gitignore
├── LICENSE
├── README.md
├── main.tf
├── outputs.tf
├── providers.tf
├── variables.tf
├── versions.tf
├── modules/
│   ├── git_repository/
│   ├── git_team/
│   ├── tfe_agent/
│   ├── tfe_team/
│   ├── tfe_workspace/
├── docs/
│   ├── CODE_OF_CONDUCT.md
│   ├── CONTRIBUTING.md
│   ├── PULL_REQUEST_TEMPLATE.md
│   ├── README_footer.md
│   ├── README_header.md
│   ├── SECURITY.md
│   ├── VCS-Provider.md
```

### Required Files and Directories

- `README.md` – Required in the root module. Generated automatically (e.g., via Terraform-Docs). Do not edit manually.
- `docs/README_header.md` - Describe the purpose of the code and provide required context.
- `docs/README_footer.md` - Provide links to external documentation used to generate the code.
- `main.tf` – Resource definitions.
- `outputs.tf` – Output value definitions (alphabetical order).
- `providers.tf` – Provider configurations.
- `variables.tf` – Input variable definitions (alphabetical order with required variables at the top).
- `versions.tf` - Terraform version and provider requirements.

## README_header.md

When editing this file, note special instructions regarding HCP Terraform configurations that cannot be managed by Terraform (e.g. API token Maximum Time to Live, Recoverable Items policy, and IP Allow lists).

## README_footer.md

When editing or creating `docs/README_footer.md`, ensure it contains:
- An `External Documentation` section providing links to relevant external documentation used to develop the code (e.g., Terraform documentation, HCP Terraform provider documentation).

## Code Guidelines

Refer to `docs/CONTRIBUTING.md` for general coding guidelines. HashiCorp's Terraform style guide should be applied for all code generated.

## Resource Naming

- Use descriptive nouns separated by underscores.
- Do not include the resource type in the resource name.
- Wrap resource type and name in double quotes.
- Example: `resource "tfe_workspace" "main"` not `resource "tfe_workspace" "tfe_workspace_main"`.

## Version Management

- Prefer the pessimistic constraint operator (`~>`) for modules and providers to allow safe updates within a compatible version range.
- Avoid using only the equals (`=`) operator unless you must lock to a single version for reproducibility or known issues.
- Pin the Terraform version using `required_version` in the `terraform` block.

## Provider Configuration

- Always include a default provider configuration.
- Define all providers in the same file (`providers.tf`).
- Define the default provider first, then aliased providers.
- Use `alias` as the first parameter in non-default provider blocks.

## Security and Secrets

- Never commit `.terraform` directories or local state files.
- Access secrets securely via workspace variables.
- Set `sensitive = true` for sensitive variables across all definitions.

## State Management

- Do NOT configure local state backend blocks or manipulate state manually. State is natively stored and handled remotely in HCP Terraform.
