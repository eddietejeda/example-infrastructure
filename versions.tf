terraform {
  required_version = ">= 0.12.26"

  required_providers {
    aws      = ">= 2.48"
    template = ">= 2.0"
  }

  backend "remote" {
    organization = "LinkBird"

    workspaces {
      name = "development"
    }
  }

  # backend "local" {
  #   path = "terraform.tfstate"
  # }
}

provider "aws" {
  region = "${local.region}"
}