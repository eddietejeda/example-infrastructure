################################################################################
# VPC
################################################################################

module "vpc" {
  source  = "terraform-aws-modules/vpc/aws"
  version = "~> 3.0"

  name = "${local.name}-vpc" 
  cidr = "10.0.0.0/16"

  azs                 = [data.aws_availability_zones.available.names[0], data.aws_availability_zones.available.names[1]]
  private_subnets     = ["10.0.1.0/24",      "10.0.2.0/24"]
  public_subnets      = ["10.0.101.0/24",    "10.0.102.0/24"]

  enable_dns_hostnames    = true
  enable_dns_support      = true

  enable_nat_gateway      = true
  single_nat_gateway      = true
  one_nat_gateway_per_az  = false
  reuse_nat_ips           = true                    # <= Skip creation of EIPs for the NAT Gateways
  external_nat_ip_ids     = "${aws_eip.nat.*.id}"   # <= IPs specified here as input to the module
  
  tags = local.tags
}

resource "aws_eip" "nat" {
  count = 1
  vpc   = true
  tags = local.tags
}

data "aws_availability_zones" "available" {
  state = "available"
}