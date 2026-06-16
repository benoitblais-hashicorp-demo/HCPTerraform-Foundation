terraform {

  required_providers {
    tfe = {
      source  = "hashicorp/tfe"
      version = "~> 0.78"
    }
  }

  required_version = ">= 1.13.0"

}
