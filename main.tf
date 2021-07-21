locals {
  name            = var.name
  region          = var.region
  environment     = var.environment
  domain_name     = var.domain_name
  domain_name2    = var.domain_name2
  public_url      = "www.${local.domain_name}"
  public_url2      = "www.${local.domain_name2}"
  container_image = var.container_image
  bucket_name     = var.bucket_name
  log_group       = "${local.name}-${local.environment}"
  database_url    = "postgres://${module.db.db_instance_username}:${module.db.db_instance_password}@${module.db.db_instance_endpoint}/${module.db.db_instance_username}"
  redis_url       = "redis://${aws_elasticache_cluster.redis.cache_nodes[0].address}:${aws_elasticache_cluster.redis.cache_nodes[0].port}"

  tags = {
    Application = "${local.name}"
    Environment = "${local.environment}"
  }
}

