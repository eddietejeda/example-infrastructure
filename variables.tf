variable "name" {
  default     = "linkbird"
  description = "The name of the application"
}

# Github 
variable "github_repo" {
  description = "Default Github repo"
}

variable "github_token" {
  description = "Github token"
}

variable "github_webhook_token" {}

variable "git_organization" {}

# Dockerhub
variable "dockerhub_username" { }

variable "dockerhub_access_token" { }


variable "github_url" {
  default = "github.com/eddietejeda/linkbird-application"
}

variable "git_branch" {
  default = "5"
}



variable "codebuild_timeout" {
  default = 5
}

variable "codebuild_buildspec_path" {}


variable "codebuild_image" {
  default = "linkbird:latest"
}




variable "region" {
  description = "The default region"
}

variable "environment" {
  description = "Examples: development, staging, production"
}

variable "domain_name" {
  description = "The primary domain name"
}

variable "domain_name2" {
  description = "The primary domain name"
}

variable "container_image" {
  description = "The name or URL of the Docker image"
}

variable "bucket_name" {
  description = "The name of the private bucket"
}

variable "private_bucket_name" {
  description = "The name of the private bucket"
}

variable "ssh_key_name" { }
