terraform {

  required_providers {
    github = {
      source  = "integrations/github"
      version = "~>6.6"
    }
  }

  required_version = ">= 1.13.0"

}