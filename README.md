## Infrastructure

This is the infrastructure to deploy my toy app, [LinkBird](https://github.com/eddietejeda/linkbird-application).


## Implements

- VPC with multiple subnets across two AZs
- Supports services like Elasticsearch and Redis
- CI/CD Pipeline
- Builds Docker images
- Manages domain and certificates and load balancers 
- Deploys to Elastic Container
- etc.

I will add functionality when needed.


## Deployment Workflow

This environment is configured to run on [Terraform Cloud](https://www.terraform.io/cloud).

Any commit to this repositiory will trigger a build in Terraform Cloud

If you run this locally, you will need to define one of the following two files.

- `variables.tfvar`      - This file be used if you want to run `apply` directly from your computer with these values.
- `variables.auto.tfvar` - This file will be passed to Terraform Cloud and run `apply` remotely with these values.

If you want to remove Terraform Cloud integration all together, remove this section form `versions.tf`

https://app.terraform.io/app/LinkBird/workspaces/production
```
  backend "remote" {
    organization = "LinkBird"

    workspaces {
      name = "production"
    }
  }
```


## Naming convention

If we expect there to only be one instance of a resource type, just call it by 

For example, we are creating only one cluster in this entire application, so we can use something like this:

- aws_ecs_cluster.cluster

But, if this is a resource type that will have multiple instances, for example:

- aws_route53_record.www
- aws_route53_record.cert_validation
