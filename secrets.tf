# Codebuild IAM data for codebuild project
data "aws_kms_alias" "s3kmskey" {
  name = "alias/aws/s3"
}

resource "aws_ssm_parameter" "github_webhook_secret" {
  name        = "/${var.name}/github/webhook"
  description = "Used by the CI/CD pipeline to create/destroy Github webhooks"
  type        = "SecureString"
  value       = "${var.github_webhook_token}"
  tags        = local.tags
}



resource "aws_ssm_parameter" "dockerhub_username" {
  name        = "/${var.name}/dockerhub/username"
  description = "Used to auth password"
  type        = "SecureString"
  value       = "${var.dockerhub_username}"
  tags        = local.tags
}


resource "aws_ssm_parameter" "dockerhub_access_token" {
  name        = "/${var.name}/dockerhub/access_token"
  description = "Used by the CI/CD pipeline to create/destroy Github webhooks"
  type        = "SecureString"
  value       = "${var.dockerhub_access_token}"
  tags        = local.tags
}



resource "aws_ssm_parameter" "dockerhub_access_token" {
  name        = "/${var.name}/dockerhub/access_token"
  description = "Used by the CI/CD pipeline to create/destroy Github webhooks"
  type        = "SecureString"
  value       = "${var.dockerhub_access_token}"
  tags        = local.tags
}



resource "aws_ssm_parameter" "app_encryption_key" {
  name        = "/${var.name}/app/encryption_key"
  description = "xxxx"
  type        = "SecureString"
  value       = "${var.app_encryption_key}"
  tags        = local.tags
}






# 

# =
# 

# =
# =


# 
resource "aws_ssm_parameter" "new_relic_license_key" {
  name        = "/${var.name}/new_relic/license_key"
  description = "xxxx"
  type        = "SecureString"
  value       = "${var.new_relic_license_key}"
  tags        = local.tags
}



resource "aws_ssm_parameter" "twitter_access_token" {
  name        = "/${var.name}/twitter/access_token"
  description = "xxxx"
  type        = "SecureString"
  value       = "${var.twitter_access_token}"
  tags        = local.tags
}



resource "aws_ssm_parameter" "twitter_access_token_secret" {
  name        = "/${var.name}/twitter/access_token_secret"
  description = "xxxx"
  type        = "SecureString"
  value       = "${var.twitter_access_token_secret}"
  tags        = local.tags
}





resource "aws_ssm_parameter" "twitter_consumer_key" {
  name        = "/${var.name}/twitter/consumer_key"
  description = "xxxx"
  type        = "SecureString"
  value       = "${var.twitter_consumer_key}"
  tags        = local.tags
}



resource "aws_ssm_parameter" "twitter_consumer_secret" {
  name        = "/${var.name}/dockerhub/access_token"
  description = "xxxx"
  type        = "SecureString"
  value       = "${var.twitter_consumer_secret}"
  tags        = local.tags
}


resource "aws_ssm_parameter" "twitter_app_access_token" {
  name        = "/${var.name}/twitter_app/token_secret"
  description = "xxxx"
  type        = "SecureString"
  value       = "${var.twitter_app_access_token}"
  tags        = local.tags
}



resource "aws_ssm_parameter" "twitter_app_consumer_key" {
  name        = "/${var.name}/twitter_app/consumer_key"
  description = "xxxx"
  type        = "SecureString"
  value       = "${var.twitter_app_consumer_key}"
  tags        = local.tags
}





resource "aws_ssm_parameter" "twitter_app_consumer_secret" {
  name        = "/${var.name}/twitter_app/consumer_secret"
  description = "xxxx"
  type        = "SecureString"
  value       = "${var.twitter_app_consumer_secret}"
  tags        = local.tags
}



resource "aws_ssm_parameter" "stripe_price_key" {
  name        = "/${var.name}/stripe/price_key"
  description = "xxxx"
  type        = "SecureString"
  value       = "${var.stripe_price_key}"
  tags        = local.tags
}



resource "aws_ssm_parameter" "stripe_product_key" {
  name        = "/${var.name}/stripe/product_key"
  description = "xxxx"
  type        = "SecureString"
  value       = "${var.stripe_product_key}"
  tags        = local.tags
}



resource "aws_ssm_parameter" "stripe_publishable_key" {
  name        = "/${var.name}/stripe/publishable_key"
  description = "xxxx"
  type        = "SecureString"
  value       = "${var.stripe_publishable_key}"
  tags        = local.tags
}



resource "aws_ssm_parameter" "stripe_secret_key" {
  name        = "/${var.name}/stripe/secret_key"
  description = "xxxx"
  type        = "SecureString"
  value       = "${var.stripe_secret_key}"
  tags        = local.tags
}
