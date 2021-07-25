resource "aws_codedeploy_app" "codedeploy" {
  name             = "${var.name}-codedeploy"
  compute_platform = "ECS"
}

resource "aws_codedeploy_deployment_group" "deployment_group" {
  app_name               = aws_codedeploy_app.codedeploy.name
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

  load_balancer_info {
    # https://docs.aws.amazon.com/codedeploy/latest/APIReference/API_TargetGroupPairInfo.html
    target_group_pair_info {
      prod_traffic_route {
        listener_arns = ["${aws_lb.load_balancer.arn}"]
      }

      target_group {
        name = "${aws_lb_target_group.target_group.name}"
      }
    }
  }
  
}






# IAM
resource "aws_iam_role" "codedeploy_role" {
  name = "${var.name}-role"

  assume_role_policy = <<EOF
{
  "Version": "2012-10-17",
  "Statement": [
    {
      "Sid": "",
      "Effect": "Allow",
      "Principal": {
        "Service": "codedeploy.amazonaws.com"
      },
      "Action": "sts:AssumeRole"
    }
  ]
}
EOF
}

resource "aws_iam_role_policy_attachment" "AWSCodeDeployRole" {
  policy_arn = "arn:aws:iam::aws:policy/service-role/AWSCodeDeployRole"
  role       = aws_iam_role.codedeploy_role.name
}