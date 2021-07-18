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





# -----------EXAMPLE

# module "asg" {
#   source  = "terraform-aws-modules/autoscaling/aws"
#   version = "~> 4.0"

#   name = local.ec2_resources_name

#   # Launch configuration
#   lc_name   = local.ec2_resources_name
#   use_lc    = true
#   create_lc = true

#   image_id                  = data.aws_ami.amazon_linux_ecs.id
#   instance_type             = "t2.micro"
#   security_groups           = [module.vpc.default_security_group_id]
#   iam_instance_profile_name = module.ec2_profile.iam_instance_profile_id
#   user_data                 = data.template_file.user_data.rendered

#   # Auto scaling group
#   vpc_zone_identifier       = module.vpc.private_subnets
#   health_check_type         = "EC2"
#   min_size                  = 0
#   max_size                  = 2
#   desired_capacity          = 1 # we don't need them for the example
#   wait_for_capacity_timeout = 0

#   tags = [
#     {
#       key                 = "Environment"
#       value               = local.environment
#       propagate_at_launch = true
#     },
#     {
#       key                 = "Cluster"
#       value               = local.name
#       propagate_at_launch = true
#     },
#   ]
# }



# resource "aws_instance" "helloworld" {
    
# }


# data "aws_subnet" "subnet_ids" {
#   for_each = data.aws_subnet_ids.subnet_ids
#   id       = each.value
# }

# resource "aws_db_subnet_group" "subnet_group" {  
#   name       = "subnet_group"  
#   subnet_ids = module.vpc.database_subnets
#   tags       = local.tags
# }



# data "template_file" "user_data" {
#   template = file("${path.module}/templates/user-data.sh")

#   vars = {
#     cluster_name = local.name
#   }
# }


# /*
#  * Create Launch Configuration
#  */
# resource "aws_launch_configuration" "lc" {
#   image_id             = aws_instance.ec2.ami
#   name_prefix          = local.cluster_name
#   instance_type        = aws_instance.ec2.instance_type
#   # iam_instance_profile = aws_iam_instance_profile.ecsInstanceProfile.id
#   security_groups      = [aws_security_group.ecs.id]
#   # user_data            = var.user_data != "false" ? var.user_data : data.template_file.user_data.rendered
#   # key_name             = var.ssh_key_name

#   # root_block_device {
#   #   volume_size = var.root_volume_size
#   # }

#   lifecycle {
#     create_before_destroy = true
#   }
# }



# /*
#  * Create Auto-Scaling Group
#  */
# resource "aws_autoscaling_group" "asg" {
#   name                      = local.cluster_name
#   # vpc_zone_identifier       = var.subnet_ids
#   min_size                  = 1
#   max_size                  = 2
#   # health_check_type         = var.health_check_type
#   # health_check_grace_period = var.health_check_grace_period
#   # default_cooldown          = var.default_cooldown
#   # termination_policies      = var.termination_policies
#   # launch_configuration      = aws_launch_configuration.lc.id

#   # tags = concat(
#   #   list(
#   #     map("key", "ecs_cluster", "value", var.cluster_name, "propagate_at_launch", true)
#   #   ),
#   #   var.tags
#   # )

#   protect_from_scale_in = false

#   lifecycle {
#     create_before_destroy = true
#   }
# }





# resource "aws_security_group" "allow_tls" {
#   name        = "allow_tls"
#   description = "Allow TLS inbound traffic"

#   ingress {
#     description      = "TLS from VPC"
#     from_port        = 443
#     to_port          = 443
#     protocol         = "tcp"
#     cidr_blocks      = module.vpc.cidr_block
#     # ipv6_cidr_blocks = [module.vpc.ipv6_cidr_block]
#   }

#   egress {
#     from_port        = 0
#     to_port          = 0
#     protocol         = "-1"
#     cidr_blocks      = ["0.0.0.0/0"]
#     ipv6_cidr_blocks = ["::/0"]
#   }

#   tags = local.tags
# }

# resource "aws_security_group" "ecs" {
#   name        = "${local.name}-ecs"
#   description = "Allow only internal VPC traffic to ECS"

#   ingress {
#     description      = "Internal VPC traffic to SC"
#     from_port        = 0
#     to_port          = 0
#     protocol         = "tcp"
#     cidr_blocks      = module.vpc.public_subnets_cidr_blocks
#     # ipv6_cidr_blocks = [module.vpc.private_subnets_ipv6_cidr_blocks]
#   }

#   egress {
#     from_port        = 0
#     to_port          = 0
#     protocol         = "-1"
#     cidr_blocks      = ["0.0.0.0/0"]
#     ipv6_cidr_blocks = ["::/0"]
#   }

#   tags = local.tags

# }


# resource "aws_ecs_capacity_provider" "prov1" {
#   name = "prov1"

#   auto_scaling_group_provider {
#     auto_scaling_group_arn = module.asg.autoscaling_group_arn
#   }

# }


#----- ECS  Resources--------

# #For now we only use the AWS ECS optimized ami <https://docs.aws.amazon.com/AmazonECS/latest/developerguide/ecs-optimized_AMI.html>
# data "aws_ami" "amazon_linux_ecs" {
#   most_recent = true

#   owners = ["amazon"]

#   filter {
#     name   = "name"
#     values = ["amzn-ami-*-amazon-ecs-optimized"]
#   }

#   filter {
#     name   = "owner-alias"
#     values = ["amazon"]
#   }
# }





# ################################################################################
# # EC2
# ################################################################################
# resource "aws_instance" "ec2" {
#   ami                     = "ami-0ab4d1e9cf9a1215a"   # Amazon Linux 2 AMI (HVM), SSD Volume Type (64-bit x86) 
#   instance_type           = "t2.micro"
#   tags                    = local.tags
# } 


