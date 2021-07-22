
resource "github_repository_webhook" "webhook" {
  repository  = "${var.github_repo}"
  events      = ["push"]
  active      = true

  configuration {
    url          = "${aws_codepipeline_webhook.webhook.url}"
    content_type = "json"
    insecure_ssl = false
    secret       = "${aws_ssm_parameter.github_webhook_secret.value}"
  }

}