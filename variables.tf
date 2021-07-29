variable "name" {
  default     = "linkbird"
  description = "The name of the application"
}



# Code build
variable "codebuild_buildspec_path" {}


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

variable "primary_domain" {
  description = "The primary domain name"
}

variable "secondary_domain" {
  description = "The secondary domain name"
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

# variable  "app_key" {} 
variable  "app_encryption_key" {} 


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

variable  "github_webhook_secret" {} 

variable  "new_relic_license_key" {} 

# Twitter tokens
variable  "twitter_access_token" {} 
variable  "twitter_access_token_secret" {} 
variable  "twitter_consumer_key" {} 
variable  "twitter_consumer_secret" {} 

# Twitter worker tokens
variable  "twitter_worker_access_token" {} 
variable  "twitter_worker_access_token_secret" {} 
variable  "twitter_worker_consumer_key" {}  
variable  "twitter_worker_consumer_secret" {} 


variable  "stripe_price_key" {} 
variable  "stripe_product_key" {} 
variable  "stripe_publishable_key" {}
variable  "stripe_secret_key" {}