output "aws_s3_bucket_arn" {
  value = "${aws_s3_bucket.bucket.arn}"
}

output "ecs_cluster_arn" {
  description = "ARN of the ECS Cluster"
  value       = concat(aws_ecs_cluster.cluster.*.arn, [""])[0]
}

output "database_url" {
  value    = "postgres://${module.db.db_instance_endpoint}"
}

output "redis_url" {
  value = "${local.redis_url}"
}

output "load_balancer_url" {
  value = "${aws_lb.load_balancer.dns_name}"
}

output "production_domain" {
  value = "https://${local.public_url}"
}