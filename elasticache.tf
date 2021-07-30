################################################################################
# Redis
################################################################################

resource "aws_elasticache_subnet_group" "redis" {
  name        = "${var.name}-redis-subnet-group"
  subnet_ids  = flatten([flatten(module.vpc.private_subnets), flatten(module.vpc.public_subnets)])
}

resource "aws_elasticache_cluster" "redis" {
  cluster_id           = "${var.name}-redis"
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



# IAM 
resource "aws_iam_role" "elasticache_role" {
  name    = "${var.name}-elasticache-role"
  path    = "/"
  tags    = local.tags
  assume_role_policy = data.aws_iam_policy_document.elasticsearch_instance_assume_role_policy.json
}

resource "aws_iam_role_policy_attachment" "elasticache_full_access_policy" {
  role       = aws_iam_role.elasticache_role.id
  policy_arn = "arn:aws:iam::aws:policy/AmazonElastiCacheFullAccess"
}

data "aws_iam_policy_document" "elasticsearch_instance_assume_role_policy" {
  statement {
    actions = ["sts:AssumeRole"]

    principals {
      type        = "Service"
      identifiers = ["es.amazonaws.com"]
    }
  }
}
