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

# TODO: Need to lock down permissions
resource "aws_iam_role_policy_attachment" "ecs_elasticache_role" {
  role       = aws_iam_role.iam_role.id
  policy_arn = "arn:aws:iam::aws:policy/AmazonElastiCacheFullAccess"
}