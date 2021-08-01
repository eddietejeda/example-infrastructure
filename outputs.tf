output "database_url" {
  value    = "postgres://${module.db.db_instance_endpoint}"
}

output "redis_url" {
  value = "${local.redis_url}"
}

output "load_balancer_url" {
  value = "${aws_alb.load_balancer.dns_name}"
}

output "public_url" {
  value = "https://${local.primary_url}"
}