locals {
  primary_url       = "www.${var.primary_domain}"
  secondary_url     = "www.${var.secondary_domain}"
  database_url      = "postgres://${module.db.db_instance_username}:${module.db.db_instance_password}@${module.db.db_instance_endpoint}/${module.db.db_instance_username}"
  redis_url         = "redis://${aws_elasticache_cluster.redis.cache_nodes[0].address}:${aws_elasticache_cluster.redis.cache_nodes[0].port}"

  tags = {
    Application = "${var.name}"
    Environment = "${var.environment}"
  }

  application_env = [
    {
      name =  "PRODUCTION_URL",
      value = "${local.primary_url}"
    },
    {
      name =  "DATABASE_URL",
      value = "${local.database_url}"
    },
    {
      name =  "REDIS_URL",
      value = "${local.redis_url}"
    },
    {
      name =  "APP_ENCRYPTION_KEY",
      value = "${var.app_encryption_key}"
    },
    {
      name =  "NEW_RELIC_LICENSE_KEY",
      value = "${var.new_relic_license_key}"
    },
    {
      name =  "TWITER_ACCESS_TOKEN",
      value = "${var.twitter_access_token}"
    },
    {
      name =  "TWITTER_ACCESS_TOKEN_SECRET",
      value = "${var.twitter_access_token_secret}"
    },
    {
      name =  "TWITTER_CONSUMER_KEY",
      value = "${var.twitter_consumer_key}"
    },
    {
      name =  "TWITTER_CONSUMER_SECRET",
      value = "${var.twitter_consumer_secret}"
    },
    {
      name =  "TWITTER_WORKER_ACCESS_TOKEN",
      value = "${var.twitter_worker_access_token}"
    },
    {
      name =  "TWITTER_WORKER_ACCESS_TOKEN_SECRET",
      value = "${var.twitter_worker_access_token_secret}"
    },
    {
      name =  "TWITTER_WORKER_CONSUMER_KEY",
      value = "${var.twitter_worker_consumer_key}"
    },
    {
      name =  "TWITTER_WORKER_CONSUMER_SECRET",
      value = "${var.twitter_worker_consumer_secret}"
    },
    {
      name =  "STRIPE_PRICE_KEY",
      value = "${var.stripe_price_key}"
    },
    {
      name =  "STRIPE_PRODUCT_KEY",
      value = "${var.stripe_product_key}"
    },
    {
      name =  "STRIPE_PUBLISHABLE_KEY",
      value = "${var.stripe_publishable_key}"
    },
    {
      name =  "STRIPE_SECRET_KEY",
      value = "${var.stripe_secret_key}"
    }
  ]
}