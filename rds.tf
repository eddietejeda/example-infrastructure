################################################################################
# RDS
################################################################################

module "db" {
  source = "terraform-aws-modules/rds/aws"
  name   = "${local.name}_db"

  engine                = "postgres"
  engine_version        = "11.10"
  family                = "postgres11"   # DB parameter group
  major_engine_version  = "11"           # DB option group
  instance_class        = "db.t3.micro"
  identifier            = "${local.name}-rds" 

  allocated_storage     = 20
  max_allocated_storage = 100
  storage_encrypted     = false

  username                = "${local.name}_user"
  create_random_password  = true
  random_password_length  = 12
  port                    = 5432

  multi_az                = false
  subnet_ids              = module.vpc.private_subnets
  vpc_security_group_ids  = [aws_security_group.managed_services.id] 

  maintenance_window              = "Mon:00:00-Mon:03:00"
  backup_window                   = "03:00-06:00"
  enabled_cloudwatch_logs_exports = ["postgresql", "upgrade"]

  backup_retention_period = 0
  skip_final_snapshot     = true
  deletion_protection     = false
  apply_immediately       = true

  performance_insights_retention_period = 7
  performance_insights_enabled          = true

  
  parameters = [
    {
      name  = "autovacuum"
      value = 1
    },
    {
      name  = "client_encoding"
      value = "utf8"
    }
  ]

  db_option_group_tags = {
    "Sensitive" = "low"
  }
  db_parameter_group_tags = {
    "Sensitive" = "low"
  }
  db_subnet_group_tags = {
    "Sensitive" = "high"
  }

  tags = local.tags
}