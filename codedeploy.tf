resource "aws_codedeploy_app" "codedeploy" {
  name             = "${var.name}-codedeploy"
  compute_platform = "ECS"
}

resource "aws_codedeploy_deployment_group" "deployment_group" {
  app_name               = aws_codedeploy_app.codedeploy.name
  deployment_config_name = "CodeDeployDefault.ECSAllAtOnce"
  deployment_group_name  = "${var.name}-codedeploy"
  service_role_arn       = aws_iam_role.codedeploy_role.arn

  auto_rollback_configuration {
    enabled = true
    events  = ["DEPLOYMENT_FAILURE"]
  }

  deployment_style {
    deployment_type   = "IN_PLACE"
  }

  ecs_service {
    cluster_name = aws_ecs_cluster.cluster.name
    service_name = aws_ecs_service.ecs_service.name
  }
}


# IAM
resource "aws_iam_role" "codedeploy_role" {
  name    = "${var.name}-codedeploy-role"
  path    = "/"
  tags    = local.tags

  assume_role_policy = data.aws_iam_policy_document.codedeploy_assume_role_policy.json
}

resource "aws_iam_instance_profile" "codedeploy_instance_profile" {
  name       = "${var.name}-codedeploy-instance-profile"
  role       = aws_iam_role.codedeploy_role.name
}

data "aws_iam_policy_document" "codedeploy_assume_role_policy" {
  statement {
    actions = ["sts:AssumeRole"]

    principals {
      type        = "Service"
      identifiers = ["ec2.amazonaws.com", "ecs.amazonaws.com"]
    }
  }
}

resource "aws_iam_role_policy_attachment" "codedeploy_role_ec2container_service" {
  role       = aws_iam_role.codedeploy_role.id
  policy_arn = "arn:aws:iam::aws:policy/service-role/AmazonEC2ContainerServiceforEC2Role"
}