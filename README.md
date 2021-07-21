## Naming convention

If we expect there to only be one instance of a resource type, just call it by 

For example, we are creating only one cluster in this entire application, so we can use something like this:

- aws_ecs_cluster.cluster

But, if this is a resource type that will have multiple instances, for example:

- aws_route53_record.www
- aws_route53_record.cert_validation
