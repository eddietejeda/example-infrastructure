################################################################################
# CloudWatch
################################################################################

resource "aws_cloudwatch_log_group" "log_group" {
  name = "${local.log_group}" 
  retention_in_days = 7
}