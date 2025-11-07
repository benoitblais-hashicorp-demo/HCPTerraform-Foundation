terraform {

  required_providers {
    github = {
      source  = "integrations/github"
      version = "~>6.6.0"
    }
    tfe = {
      source  = "hashicorp/tfe"
      version = "~>0.70"
    }
  }

  required_version = ">= 1.13.0"

}
