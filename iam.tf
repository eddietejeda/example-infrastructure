################################################################################
# IAM
################################################################################

resource "aws_iam_role" "iam_role" {
  name    = "${var.name}-primary-role"
  path    = "/"
  tags    = local.tags

  assume_role_policy = data.aws_iam_policy_document.instance-assume-role-policy.json
}
resource "aws_iam_instance_profile" "iam_instance_profile" {
  name       = "${var.name}-instance-profile"
  role       = aws_iam_role.iam_role.name
}

data "aws_iam_policy_document" "instance-assume-role-policy" {
  statement {
    actions = ["sts:AssumeRole"]

    principals {
      type        = "Service"
      identifiers = ["ec2.amazonaws.com", "ecs.amazonaws.com", "ecs-tasks.amazonaws.com", "s3.amazonaws.com"]
    }
  }
}

resource "aws_iam_role_policy_attachment" "ecs_ec2_role" {
  role       = aws_iam_role.iam_role.id
  policy_arn = "arn:aws:iam::aws:policy/service-role/AmazonEC2ContainerServiceforEC2Role"
}

resource "aws_iam_role_policy_attachment" "ecs_task_execution_role" {
  role       = aws_iam_role.iam_role.id
  policy_arn = "arn:aws:iam::aws:policy/service-role/AmazonECSTaskExecutionRolePolicy"
}

resource "aws_iam_role_policy_attachment" "ecs_task_role" {
  role       = aws_iam_role.iam_role.id
  policy_arn = "arn:aws:iam::aws:policy/service-role/AmazonEC2ContainerServiceRole"
}

# TODO: Need to lock down permissions
resource "aws_iam_role_policy_attachment" "ecs_ec2_cloudwatch_role" {
  role       = aws_iam_role.iam_role.id
  policy_arn = "arn:aws:iam::aws:policy/CloudWatchLogsFullAccess"
}

# # TODO: Need to lock down permissions
# resource "aws_iam_role_policy_attachment" "ecs_elasticache_role" {
#   role       = aws_iam_role.iam_role.id
#   policy_arn = "arn:aws:iam::aws:policy/AmazonElastiCacheFullAccess"
# }