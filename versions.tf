terraform {

  required_providers {
    tfe = {
      source  = "hashicorp/tfe"
      version = "~>0.70"
    }
    github = {
      source  = "integrations/github"
      version = "6.6.0"
    }
  }

  cloud {
    organization = "benoitblais-hashicorp"

    workspaces {
      name = "HCPTerraform-Foundation"
    }
  }

  required_version = ">= 1.13.0"

}