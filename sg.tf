################################################################################
# Security Groups
################################################################################

#-------------------------------------------
# Load Balancer 
#-------------------------------------------
resource "aws_security_group" "load_balancer" {
  name        = "${var.name}-public-load-balancer-security-group"
  description = "Controls access to the load balancer"
  vpc_id      = module.vpc.vpc_id
  tags        = merge({ Name = "${var.name}-load-balancer" }, local.tags )
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
  name        = "${var.name}-public-web-worker-security-group"
  description = "Allow HTTP inbound traffic"
  vpc_id      = "${module.vpc.vpc_id}"
  tags = merge(
    local.tags,
    {
      Name = "${var.name}-web-workers"
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
  name        = "${var.name}-private-worker-security-group"
  description = "Allow inbound access from the ALB only"
  vpc_id      = module.vpc.vpc_id
  tags = merge(
    local.tags,
    {
      Name = "${var.name}-private-workers"
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
  name        = "${var.name}-private-services-security-group"
  description = "Private managed services"
  vpc_id      = "${module.vpc.vpc_id}"
  tags        = merge(
    local.tags,
    {
      Name = "${var.name}-private-services"
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