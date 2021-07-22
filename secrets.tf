# Codebuild IAM data for codebuild project
data "aws_kms_alias" "s3kmskey" {
  name = "alias/aws/s3"
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


resource "aws_ssm_parameter" "github_webhook_secret" {
  name        = "/${var.name}/github/webhook"
  description = "Used by the CI/CD pipeline to create/destroy Github webhooks"
  type        = "SecureString"
  value       = "${var.github_webhook_token}"
  tags        = local.tags
}


