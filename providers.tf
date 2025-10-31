provider "github" {
  app_auth {} # Required when using `GITHUB_APP_XXX` environment variables
}

provider "hcp" {}

provider "tfe" {}
