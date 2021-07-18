locals {
  name            = "linkbird"
  region          = "us-east-1"
  environment     = "dev"
  include_ssm     = true
  domain_name     = "linkbirdapp.com"
  public_url      = "www.${local.domain_name}"
  container_image = "497668422660.dkr.ecr.us-east-1.amazonaws.com/linkbird:latest"
  bucket_name     = "linkbird-private-bucket"
  log_group       = "${local.name}-${local.environment}"
  database_url    = "postgres://${module.db.db_instance_username}:${module.db.db_instance_password}@${module.db.db_instance_endpoint}/${module.db.db_instance_username}"
  redis_url       = "redis://${aws_elasticache_cluster.redis.cache_nodes[0].address}:${aws_elasticache_cluster.redis.cache_nodes[0].port}"

  tags = {
    Application = "${local.name}"
    Environment = "${local.environment}"
  }
}


################################################################################
# VPC
################################################################################

module "vpc" {
  source  = "terraform-aws-modules/vpc/aws"
  version = "~> 3.0"

  name = "${local.name}-vpc" 
  cidr = "10.0.0.0/16"

  azs                 = [data.aws_availability_zones.available.names[0], data.aws_availability_zones.available.names[1]]
  private_subnets     = ["10.0.1.0/24",      "10.0.2.0/24"]
  public_subnets      = ["10.0.101.0/24",    "10.0.102.0/24"]

  enable_dns_hostnames    = true
  enable_dns_support      = true

  enable_nat_gateway      = true
  single_nat_gateway      = true
  one_nat_gateway_per_az  = false
  reuse_nat_ips           = true                    # <= Skip creation of EIPs for the NAT Gateways
  external_nat_ip_ids     = "${aws_eip.nat.*.id}"   # <= IPs specified here as input to the module
  
  tags = local.tags
}

resource "aws_eip" "nat" {
  count = 1
  vpc   = true
  tags = local.tags
}

data "aws_availability_zones" "available" {
  state = "available"
}


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
  family                   = local.name
  network_mode             = "awsvpc"
  requires_compatibilities = ["FARGATE"]
  cpu                      = 1024
  memory                   = 2048
  task_role_arn            = aws_iam_role.iam_role.arn
  execution_role_arn       = aws_iam_role.iam_role.arn

  container_definitions = jsonencode([
    {
      "name": "app",
      "image": "${local.container_image}",
      "cpu":    256,
      "memory": 512,
      "links": [],
      "portMappings": [{
        "containerPort":  9292,
        "hostPort":       9292,
        "protocol":       "tcp"
      }],
      "essential": true,
      "entryPoint": ["./entrypoints/app-entrypoint.sh"],
      "command": [],
      "environment": [
        {
          "name": "DATABASE_URL",
          "value": "${local.database_url}"
        },
        {
          "name": "REDIS_URL",
          "value": "${local.redis_url}"
        }

      ],
      "environmentFiles": [{
        "value": "${aws_s3_bucket.bucket.arn}/${local.environment}.env",
        "type": "s3"
      }],      
      "logConfiguration":{
        "logDriver":"awslogs",
        "options":{  
          "awslogs-group": "${local.log_group}",
          "awslogs-region": "${local.region}",
          "awslogs-stream-prefix": "${local.name}-app"
        }
      }
    },
    {
      "name": "worker",
      "image": "${local.container_image}",
      "cpu": 256,
      "memory": 512,
      "links": [],
      "portMappings": [],
      "essential": true,
      "entryPoint": ["./entrypoints/worker-entrypoint.sh"],
      "environment": [
        {
          "name": "DATABASE_URL",
          "value": "${local.database_url}"
        },
        {
          "name": "REDIS_URL",
          "value": "${local.redis_url}"
        }
      ],
      "environmentFiles": [{
        "value": "${aws_s3_bucket.bucket.arn}/${local.environment}.env",
        "type": "s3"
      }],      
      "logConfiguration":{
        "logDriver":"awslogs",
        "options":{  
          "awslogs-group": "${local.log_group}",
          "awslogs-region": "${local.region}",
          "awslogs-stream-prefix": "${local.name}-worker"
        }
      }
    },
    {
      "name": "cron",
      "image": "${local.container_image}",
      "cpu": 256,
      "memory": 512,
      "links": [],
      "portMappings": [],
      "essential": true,
      "entryPoint": ["./entrypoints/cron-entrypoint.sh"],
      "environment": [
        {
          "name": "DATABASE_URL",
          "value": "${local.database_url}"
        },
        {
          "name": "REDIS_URL",
          "value": "${local.redis_url}"
        }
      ],
      "environmentFiles": [{
        "value": "${aws_s3_bucket.bucket.arn}/${local.environment}.env",
        "type": "s3"
      }],      
      "logConfiguration":{
        "logDriver":"awslogs",
        "options":{  
          "awslogs-group": "${local.log_group}",
          "awslogs-region": "${local.region}",
          "awslogs-stream-prefix": "${local.name}-cron"
        }
      }
    }
  ])
}



resource "aws_ecs_service" "ecs_service" {
  name            = "${local.name}-service" 
  cluster         = aws_ecs_cluster.cluster.id
  task_definition = aws_ecs_task_definition.task_definition.arn

  desired_count                      = 2
  deployment_maximum_percent         = 200
  deployment_minimum_healthy_percent = 50

  load_balancer {
    target_group_arn = aws_lb_target_group.target_group.arn
    container_name = "app"
    container_port = 9292
  }

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



################################################################################
# Application Load Balancer
################################################################################

resource "aws_lb_target_group" "target_group" {
  name        = "${local.name}-target-group"
  port        = 80
  protocol    = "HTTP"
  vpc_id      = module.vpc.vpc_id
  target_type = "ip"

  health_check {
    protocol            = "HTTP"
    matcher             = "200"
    path                = "/about"
    interval            = 300
    healthy_threshold   = 2
    timeout             = 5
    unhealthy_threshold = 2
  }

  lifecycle {
    create_before_destroy = true
  }
}


resource "aws_lb" "load_balancer" {
  name            = "${local.name}-load-balancer"
  subnets         = module.vpc.public_subnets
  security_groups = [ 
    aws_security_group.load_balancer.id, 
    aws_security_group.web.id, 
    aws_security_group.workers.id, 
    aws_security_group.managed_services.id
  ]
}


# Forward all traffic from the ALB to the target group
resource "aws_lb_listener" "https_lb_listener" {
  load_balancer_arn = aws_lb.load_balancer.id
  certificate_arn   = aws_acm_certificate.cert.arn
  protocol          = "HTTPS"
  ssl_policy        = "ELBSecurityPolicy-2016-08"
  port              = 443

  default_action {
    target_group_arn = aws_lb_target_group.target_group.id
    type             = "forward"
  }

  tags = local.tags
}

# Redirect all http traffic from the ALB to the https listener
resource "aws_lb_listener" "http_lb_listener" {
  load_balancer_arn = aws_lb.load_balancer.id
  port              = 80
  protocol          = "HTTP"

  default_action {
    type = "redirect"
    redirect {
      port        = "443"
      protocol    = "HTTPS"
      status_code = "HTTP_301"
    }
  }

  tags = local.tags
}




################################################################################
# ACM
################################################################################

resource "aws_acm_certificate" "cert" {
  domain_name       = "${aws_route53_record.www.fqdn}"
  validation_method = "DNS"

  lifecycle {
    create_before_destroy = true
  }

  provisioner "local-exec" {
    command = "sleep 10"
  }

  tags = local.tags
}

resource "aws_lb_listener_certificate" "lb_listener_certificate" {
  depends_on = [aws_acm_certificate_validation.certificate_validation]
  listener_arn    = aws_lb_listener.https_lb_listener.arn
  certificate_arn = aws_acm_certificate.cert.arn
}


resource "aws_acm_certificate_validation" "certificate_validation" {
  certificate_arn         = "${aws_acm_certificate.cert.arn}"
  validation_record_fqdns = [for record in aws_route53_record.cert_validation : record.fqdn]

  # Optional: Hook to add delay before aws_lb_listener_certificate.lb_listener_certificate
  # provisioner "local-exec" {
  #   command = "sleep 10"
  # }
}


################################################################################
# Route 53
################################################################################

resource "aws_route53_zone" "zone" {
  name  = local.domain_name
  tags  = local.tags
}

resource "aws_route53_record" "www" {
  zone_id = aws_route53_zone.zone.zone_id
  name    = "${local.public_url}"
  type    = "CNAME"
  ttl     = "300"
  records = [aws_lb.load_balancer.dns_name]
}


resource "aws_route53_record" "cert_validation" {
  for_each = {
    for dvo in aws_acm_certificate.cert.domain_validation_options : dvo.domain_name => {
      name   = dvo.resource_record_name
      record = dvo.resource_record_value
      type   = dvo.resource_record_type
    }
  }

  allow_overwrite = true
  name            = each.value.name
  records         = [each.value.record]
  ttl             = 60
  type            = each.value.type
  zone_id         = aws_route53_zone.zone.zone_id
}



################################################################################
# SES
################################################################################

resource "aws_ses_domain_mail_from" "mailer" {
  domain           = aws_ses_domain_identity.mailer.domain
  mail_from_domain = "bounce.${aws_ses_domain_identity.mailer.domain}"
}

# Mailer SES Domain Identity
resource "aws_ses_domain_identity" "mailer" {
  domain = local.domain_name
}

# Mailer Route53 MX record
resource "aws_route53_record" "mailer_ses_domain_mail_from_mx" {
  zone_id = aws_route53_zone.zone.id
  name    = aws_ses_domain_mail_from.mailer.mail_from_domain
  type    = "MX"
  ttl     = "600"
  records = ["10 feedback-smtp.us-east-1.amazonses.com"] # Change to the region in which `aws_ses_domain_identity.mailer` is created
}

# Mailer Route53 TXT record for SPF
resource "aws_route53_record" "mailer_ses_domain_mail_from_txt" {
  zone_id = aws_route53_zone.zone.id
  name    = aws_ses_domain_mail_from.mailer.mail_from_domain
  type    = "TXT"
  ttl     = "600"
  records = ["v=spf1 include:amazonses.com -all"]
}


################################################################################
# RDS
################################################################################

module "db" {
  source = "terraform-aws-modules/rds/aws"
  name   = "${local.name}_db"

  engine                = "postgres"
  engine_version        = "11.10"
  family                = "postgres11"   # DB parameter group
  major_engine_version  = "11"           # DB option group
  instance_class        = "db.t3.micro"
  identifier            = "${local.name}-rds" 

  allocated_storage     = 20
  max_allocated_storage = 100
  storage_encrypted     = false

  username                = "${local.name}_user"
  create_random_password  = true
  random_password_length  = 12
  port                    = 5432

  multi_az                = false
  subnet_ids              = module.vpc.private_subnets
  vpc_security_group_ids  = [aws_security_group.managed_services.id] 

  maintenance_window              = "Mon:00:00-Mon:03:00"
  backup_window                   = "03:00-06:00"
  enabled_cloudwatch_logs_exports = ["postgresql", "upgrade"]

  backup_retention_period = 0
  skip_final_snapshot     = true
  deletion_protection     = false
  apply_immediately       = true

  performance_insights_retention_period = 7
  performance_insights_enabled          = true

  
  parameters = [
    {
      name  = "autovacuum"
      value = 1
    },
    {
      name  = "client_encoding"
      value = "utf8"
    }
  ]

  db_option_group_tags = {
    "Sensitive" = "low"
  }
  db_parameter_group_tags = {
    "Sensitive" = "low"
  }
  db_subnet_group_tags = {
    "Sensitive" = "high"
  }

  tags = local.tags
}


################################################################################
# Redis
################################################################################

resource "aws_elasticache_subnet_group" "redis" {
  name        = "${local.name}-redis-subnet-group"
  subnet_ids  = flatten([flatten(module.vpc.private_subnets), flatten(module.vpc.public_subnets)])
}


resource "aws_elasticache_cluster" "redis" {
  cluster_id           = "${local.name}-redis"
  engine               = "redis"
  node_type            = "cache.t3.micro"
  num_cache_nodes      = 1
  parameter_group_name = "default.redis6.x"
  security_group_ids   = ["${aws_security_group.managed_services.id}"]
  subnet_group_name    = "${aws_elasticache_subnet_group.redis.name}"

  engine_version       = "6.x"
  apply_immediately    = true
  port                 = 6379
}

################################################################################
# Security Groups
################################################################################

#-------------------------------------------
# Load Balancer 
#-------------------------------------------
resource "aws_security_group" "load_balancer" {
  name        = "${local.name}-public-load-balancer-security-group"
  description = "Controls access to the load balancer"
  vpc_id      = module.vpc.vpc_id

  tags = merge(local.tags,
    {
      Name = "${local.name}-load-balancer"
    }
  )
}
resource "aws_security_group_rule" "load_balancer_allow_all_outbound" {
  type              = "egress"
  to_port           = 0
  from_port         = 0
  protocol          = "-1"
  cidr_blocks       = ["0.0.0.0/0"]
  security_group_id = aws_security_group.load_balancer.id
}
resource "aws_security_group_rule" "load_balancer_allow_http_inbound" {
  type              = "ingress"
  from_port         = 80
  to_port           = 80
  protocol          = "tcp"
  cidr_blocks       = ["0.0.0.0/0"] #!
  security_group_id = aws_security_group.load_balancer.id
}
resource "aws_security_group_rule" "load_balancer_allow_https_inbound" {
  type              = "ingress"
  from_port         = 443
  to_port           = 443
  protocol          = "tcp"
  cidr_blocks       = ["0.0.0.0/0"] #!
  security_group_id = aws_security_group.load_balancer.id
}


#-------------------------------------------
# Web Security Group
#-------------------------------------------
resource "aws_security_group" "web" {
  name        = "${local.name}-public-web-worker-security-group"
  description = "Allow HTTP inbound traffic"
  vpc_id      = "${module.vpc.vpc_id}"
  tags = merge(
    local.tags,
    {
      Name = "${local.name}-web-workers"
    }
  )
}
resource "aws_security_group_rule" "web_allow_all_outbound" {
  type              = "egress"
  to_port           = 0
  from_port         = 0
  protocol          = "-1"
  cidr_blocks       = ["0.0.0.0/0"]
  security_group_id = aws_security_group.web.id
}
resource "aws_security_group_rule" "web_allow_http_inbound" {
  type              = "ingress"
  from_port         = 80
  to_port           = 80
  protocol          = "tcp"
  cidr_blocks       = ["0.0.0.0/0"] #!
  security_group_id = aws_security_group.web.id
}
resource "aws_security_group_rule" "web_allow_https_inbound" {
  type              = "ingress"
  from_port         = 443
  to_port           = 443
  protocol          = "tcp"
  cidr_blocks       = ["0.0.0.0/0"] #!
  security_group_id = aws_security_group.web.id
}

#-------------------------------------------
# Workers Security Group
#-------------------------------------------
resource "aws_security_group" "workers" {
  name        = "${local.name}-private-worker-security-group"
  description = "Allow inbound access from the ALB only"
  vpc_id      = module.vpc.vpc_id
  tags = merge(
    local.tags,
    {
      Name = "${local.name}-private-workers"
    }
  )
}
resource "aws_security_group_rule" "workers_allow_all_outbound" {
  type              = "egress"
  to_port           = 0
  from_port         = 0
  protocol          = "-1"
  cidr_blocks       = ["0.0.0.0/0"] #!
  security_group_id = aws_security_group.workers.id
}
resource "aws_security_group_rule" "workers_allow_worker_inbound" {
  type              = "ingress"
  to_port           = 0
  from_port         = 0
  protocol          = "-1"
  cidr_blocks       = ["10.0.0.0/16"] #!
  security_group_id = aws_security_group.workers.id
}


#-------------------------------------------
# Managed Services Security Group
#-------------------------------------------
resource "aws_security_group" "managed_services" {
  name        = "${local.name}-private-services-security-group"
  description = "Private managed services"
  vpc_id      = "${module.vpc.vpc_id}"
  tags        = merge(
    local.tags,
    {
      Name = "${local.name}-private-services"
    }
  )
}
resource "aws_security_group_rule" "managed_services_allow_all_outbound" {
  description              = "Allow all outbound traffic"
  type                     = "egress"
  from_port                = 0
  to_port                  = 0
  protocol                 = "-1"
  cidr_blocks              = ["0.0.0.0/0"]
  security_group_id        = aws_security_group.managed_services.id
}
resource "aws_security_group_rule" "managed_services_allow_vpc_postgres_inbound" {
  description              = "Allow Postgres inbound traffic from trusted VPC"
  type                     = "ingress"
  from_port                = 5432
  to_port                  = 5432
  protocol                 = "tcp"
  cidr_blocks              = ["10.0.0.0/16"] #!
  security_group_id        = aws_security_group.managed_services.id
}
resource "aws_security_group_rule" "managed_services_allow_vpc_redis_inbound" {
  description              = "Allow Redis inbound traffic from trusted VPC"
  type                     = "ingress"
  from_port                = 6379
  to_port                  = 6379
  protocol                 = "tcp"
  cidr_blocks              = ["10.0.0.0/16"] #!
  security_group_id        = aws_security_group.managed_services.id
}


################################################################################
# CloudWatch
################################################################################
resource "aws_cloudwatch_log_group" "log_group" {
  name = "${local.log_group}" 
  retention_in_days = 7
}



################################################################################
# S3
################################################################################
resource "aws_s3_bucket" "bucket" {
  bucket          = "${local.bucket_name}"
  acl             = "private"
  force_destroy   = true
  tags            = local.tags
}

resource "aws_s3_bucket_object" "object" {
  bucket          = aws_s3_bucket.bucket.id
  key             =  "dev.env"
  source          = "secrets/dev.env"
  etag            = filemd5("secrets/dev.env")
}

resource "aws_s3_bucket_policy" "bucket_policy" {
  bucket = aws_s3_bucket.bucket.id
  policy = jsonencode({
   "Version":"2012-10-17",
   "Statement":[
      {
        "Effect":"Allow",
        "Action":[
          "s3:*",
        ],
        "Resource": [
          "${aws_s3_bucket.bucket.arn}",
          "${aws_s3_bucket.bucket.arn}/*"
        ],
        "Principal": {
          "AWS": "${aws_iam_role.iam_role.arn}"
        }
      }
   ]
  })
}



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

# TODO: Need to lock down permissions
resource "aws_iam_role_policy_attachment" "ecs_elasticache_role" {
  role       = aws_iam_role.iam_role.id
  policy_arn = "arn:aws:iam::aws:policy/AmazonElastiCacheFullAccess"
}


