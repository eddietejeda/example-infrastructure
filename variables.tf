# App
variable "name" {
  default     = "linkbird"
  description = "The name of the application"
}

variable "environment" {
  description = "Examples: development, staging, production"
}

# variable  "app_key" {} 
variable  "app_encryption_key" {} 


# AWS
variable "region" {
  description = "The default region"
}

variable "primary_domain" {
  description = "The primary domain name"
}

variable "secondary_domain" {
  description = "The secondary domain name"
}

variable "bucket_name" {
  description = "The name of the private bucket"
}


# Github 
variable "github_repo" {}
variable "github_token" {}
variable "github_webhook_secret" {} 
variable "github_webhook_token" {}
variable "git_organization" {}
variable "github_repository" {}
variable "github_url" {}
variable "git_branch" {
  default = "main"
}

# Dockerhub
variable "dockerhub_username" {}
variable "dockerhub_access_token" {}

# New Relic
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

# Stripe
variable  "stripe_price_key" {} 
variable  "stripe_product_key" {} 
variable  "stripe_publishable_key" {}
variable  "stripe_secret_key" {}

# Code build
variable "codebuild_buildspec_path" {}
variable "codebuild_timeout" {}
variable "codebuild_image" {}

