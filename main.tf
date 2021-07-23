locals {
  name            = var.name
  region          = var.region
  environment     = var.environment
  domain_name     = var.domain_name
  domain_name2    = var.domain_name2
  public_url      = "www.${local.domain_name}"
  public_url2      = "www.${local.domain_name2}"
  bucket_name     = var.bucket_name
  log_group       = "${local.name}-${local.environment}"
  database_url    = "postgres://${module.db.db_instance_username}:${module.db.db_instance_password}@${module.db.db_instance_endpoint}/${module.db.db_instance_username}"
  redis_url       = "redis://${aws_elasticache_cluster.redis.cache_nodes[0].address}:${aws_elasticache_cluster.redis.cache_nodes[0].port}"

  tags = {
    Application = "${local.name}"
    Environment = "${local.environment}"
  }

  application_env = [
      {
        name =  "PRODUCTION_URL",
        value = "${local.public_url}"
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
        name =  "TWITTER_APP_ACCESS_TOKEN",
        value = "${var.twitter_app_access_token}"
      },
      {
        name =  "TWITTER_APP_ACCESS_CONSUMER_KEY",
        value = "${var.twitter_app_access_consumer_key}"
      },
      {
        name =  "TWITTER_APP_CONSUMER_KEY",
        value = "${var.twitter_app_consumer_key}"
      },
      {
        name =  "TWITTER_APP_CONSUMER_SECRET",
        value = "${var.twitter_app_consumer_secret}"
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

