################################################################################
# ECS
################################################################################

resource "aws_ecs_cluster" "cluster" {
  name = "${local.name}-cluster" 
  capacity_providers = ["FARGATE_SPOT", "FARGATE"]

  default_capacity_provider_strategy {
    capacity_provider = "FARGATE"
  }
  
  setting {
    name  = "containerInsights"
    value = "enabled"
  }

  tags = local.tags
}

resource "aws_ecs_task_definition" "task_definition" {
  family                    = local.name
  network_mode              = "awsvpc"
  requires_compatibilities  = ["FARGATE"]
  cpu                       = 1024
  memory                    = 2048
  task_role_arn             = aws_iam_role.iam_role.arn
  execution_role_arn        = aws_iam_role.iam_role.arn

  # We image_digest to force ECS to redeploy on every push if there is a change to the docker image
  container_definitions = jsonencode([
    {
      "name":   "app",
      "image":  "${aws_ecr_repository.repository.repository_url}@${data.aws_ecr_image.image.image_digest}",
      "cpu":    256,
      "memory": 512,
      "links":  [],
      "portMappings": [{
        "containerPort":  9292,
        "hostPort":       9292,
        "protocol":       "tcp"
      }],
      "essential":    true,
      "entryPoint":   ["./entrypoints/app-entrypoint.sh"],
      "command":      [],
      "environment":  local.application_env,
      "environmentFiles": [{
        "value": "${aws_s3_bucket.bucket.arn}/${local.environment}.env",
        "type": "s3"
      }],      
      "logConfiguration":{
        "logDriver":"awslogs",
        "options":{  
          "awslogs-group": "${local.log_group}",
          "awslogs-region": "${local.region}",
          "awslogs-stream-prefix": "${local.name}"
        }
      }
    },
    {
      "name": "worker",
      "image": "${aws_ecr_repository.repository.repository_url}@${data.aws_ecr_image.image.image_digest}",
      "cpu": 256,
      "memory": 512,
      "links": [],
      "portMappings": [],
      "essential": true,
      "entryPoint": ["./entrypoints/worker-entrypoint.sh"],
      "environment": local.application_env,
      "environmentFiles": [{
        "value": "${aws_s3_bucket.bucket.arn}/${local.environment}.env",
        "type": "s3"
      }],      
      "logConfiguration":{
        "logDriver":"awslogs",
        "options":{  
          "awslogs-group": "${local.log_group}",
          "awslogs-region": "${local.region}",
          "awslogs-stream-prefix": "${local.name}"
        }
      }
    },
    {
      "name": "cron",
      "image": "${aws_ecr_repository.repository.repository_url}@${data.aws_ecr_image.image.image_digest}",
      "cpu": 256,
      "memory": 512,
      "links": [],
      "portMappings": [],
      "essential": true,
      "entryPoint": ["./entrypoints/cron-entrypoint.sh"],
      "environment": local.application_env,
      "environmentFiles": [{
        "value": "${aws_s3_bucket.bucket.arn}/${local.environment}.env",
        "type": "s3"
      }],      
      "logConfiguration":{
        "logDriver":"awslogs",
        "options":{  
          "awslogs-group": "${local.log_group}",
          "awslogs-region": "${local.region}",
          "awslogs-stream-prefix": "${local.name}"
        }
      }
    }
  ])
}

resource "aws_ecs_service" "ecs_service" {
  name            = "${local.name}-service" 
  cluster         = aws_ecs_cluster.cluster.id
  task_definition = aws_ecs_task_definition.task_definition.arn

  desired_count                       = 1
  deployment_maximum_percent          = 200
  deployment_minimum_healthy_percent  = 50
  force_new_deployment                = true

  # load_balancer {
  #   target_group_arn = aws_lb_target_group.target_group.arn
  #   container_name = "app"
  #   container_port = 9292
  # }

  network_configuration {
    subnets           = module.vpc.public_subnets 
    security_groups   = [
      aws_security_group.load_balancer.id, 
      aws_security_group.web.id, 
      aws_security_group.workers.id,
      aws_security_group.managed_services.id
    ]
    assign_public_ip  = true
  }

  capacity_provider_strategy {
    capacity_provider = "FARGATE_SPOT"
    weight            = "1"
  }
}