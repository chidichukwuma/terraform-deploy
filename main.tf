resource "aws_eip" "nat" {
  count = 2
  vpc   = true
}

resource "aws_kms_key" "test_key" {
  description             = "Key to use when encrypting log"
  deletion_window_in_days = 7
}


#Creating the VPC
module "vpc" {
  source  = "terraform-aws-modules/vpc/aws"
  version = "3.14.2"

  database_subnet_assign_ipv6_address_on_creation    = true
  database_subnet_group_name                         = "test_db_sub"
  default_network_acl_name                           = "test_nacl"
  default_route_table_name                           = "test_rtb"
  default_security_group_name                        = "test_sg"
  default_vpc_name                                   = "test_vpc"
  elasticache_subnet_assign_ipv6_address_on_creation = true
  elasticache_subnet_group_name                      = "test_elasticache"
  enable_classiclink                                 = false
  enable_classiclink_dns_support                     = false
  flow_log_cloudwatch_log_group_kms_key_id           = aws_kms_key.test_key.arn
  flow_log_cloudwatch_log_group_retention_in_days    = 30
  flow_log_log_format                                = ""
  intra_subnet_assign_ipv6_address_on_creation       = true
  outpost_arn                                        = ""
  outpost_az                                         = ""
  outpost_subnet_assign_ipv6_address_on_creation     = false
  private_subnet_assign_ipv6_address_on_creation     = false
  public_subnet_assign_ipv6_address_on_creation      = false
  redshift_subnet_assign_ipv6_address_on_creation    = false
  redshift_subnet_group_name                         = "redshift_subnet"
  vpc_flow_log_permissions_boundary                  = ""
  vpn_gateway_az                                     = var.vpn_gateway_availability_zone
  azs                                                = var.availability_zones
  cidr                                               = var.vpc_cidr_block
  name                                               = "test-vpc"
  private_subnets                                    = var.private_subnets
  public_subnets                                     = var.public_subnets

  enable_nat_gateway = true
  enable_vpn_gateway = true

  single_nat_gateway  = false
  reuse_nat_ips       = true
  external_nat_ip_ids = "${aws_eip.nat.*.id}"
}

output "vpc_id" {
  value = module.vpc.vpc_id
}

output "private_subnets_id" {
  value = module.vpc.private_subnets
}

output "public_subnets_id" {
  value = module.vpc.public_subnets
}


#Creating the Kubernetes Cluster
module "eks" {
  source  = "terraform-aws-modules/eks/aws"
  version = "~> 18.0"

  cluster_name    = "test-cluster"
  cluster_version = "1.22"


  vpc_id     = module.vpc.vpc_id
  subnet_ids = ["${module.vpc.private_subnets[0]}", "${module.vpc.private_subnets[1]}", "${module.vpc.public_subnets[0]}", "${module.vpc.public_subnets[1]}"]


  # EKS Managed Node Group(s)
  eks_managed_node_group_defaults = {
    disk_size      = 100
    instance_types = ["t2.medium"]
  }

  eks_managed_node_groups = {
    # blue = {}
    green = {
      min_size     = 1
      max_size     = 10
      desired_size = 2

      instance_types = ["t2.medium"]
      #   capacity_type  = "SPOT"
    }
  }


  # aws-auth configmap
  manage_aws_auth_configmap = false

  aws_auth_roles = [
    {
      rolearn  = "arn:aws:iam::**********:user/devops"
      username = "devops"
      groups   = ["system:masters"]
    }
  ]

  aws_auth_users = [
    {
      userarn  = "arn:aws:iam::**********:user/Chidi"
      username = "Chidi"
      groups   = ["system:masters"]
    }
  ]

  aws_auth_accounts = [
    "**********"
  ]

}
