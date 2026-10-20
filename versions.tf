terraform {

  required_providers {
    github = {
      source  = "integrations/github"
      version = "~> 6.13.0"
    }
    tfe = {
      source  = "hashicorp/tfe"
      version = "~> 0.82"
    }
    time = {
      source  = "hashicorp/time"
      version = "~> 0.14"
    }
  }

  required_version = ">= 1.13.0"

}
