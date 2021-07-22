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

variable "github_repository" {}

variable "github_url" {}

# Dockerhub
variable "dockerhub_username" {}

variable "dockerhub_access_token" {}


# Code build
variable "codebuild_buildspec_path" {}


# SSH
variable "ssh_key_name" {}

variable "git_branch" {
  default = "main"
}

variable "codebuild_timeout" {
  default = 5
}

# AWS
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

variable "codebuild_image" {
  default = "linkbird:latest"
}

variable "bucket_name" {
  description = "The name of the private bucket"
}

variable "private_bucket_name" {
  description = "The name of the private bucket"
}


variable  "github_webhook_secret" {} 
variable  "app_encryption_key" {} 
variable  "new_relic_license_key" {} 

variable  "twitter_access_token" {} 
variable  "twitter_access_token_secret" {} 

variable  "twitter_consumer_key" {} 
variable  "twitter_consumer_secret" {} 


variable  "twitter_app_access_token" {} 
variable  "twitter_app_access_consumer_key" {} 


variable  "twitter_app_consumer_key" {} 
variable  "twitter_app_consumer_secret" {} 


variable  "stripe_price_key" {} 
variable  "stripe_product_key" {} 
variable  "stripe_publishable_key" {}
variable  "stripe_secret_key" {}