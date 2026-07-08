terraform {

  required_providers {
    github = {
      source  = "integrations/github"
      version = "~> 6.13.0"
    }
    tfe = {
      source  = "hashicorp/tfe"
      version = "~> 0.78"
    }
  }

  required_version = ">= 1.13.0"

}
