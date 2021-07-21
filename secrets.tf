resource "aws_ssm_parameter" "dockerhub_access_token" {
  name        = "/${var.name}/dockerhub/token"
  description = "Used to auth password"
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