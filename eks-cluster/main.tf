data "aws_availability_zones" "azs" {}
module "jenkins-vpc" {
  source = "terraform-aws-modules/vpc/aws"

  name = "jenkins-vpc"
  cidr = var.cidr

  azs             = data.aws_availability_zones.azs.names
  private_subnets = var.private_subnet_vpc_cidr
  public_subnets  = var.public_subnet_vpc_cidr

  enable_nat_gateway = true
  enable_vpn_gateway = true
  enable_dns_hostnames = true

  tags = {
    "kubernetes.io/cluster/jenkins-eks-cluster" = "shared"

  }
  public_subnet_tags = {
    "kubernetes.io/cluster/jenkins-eks-cluster" = "shared"
    "kubernetes.io/role/elb" = 1
  }
  private_subnet_tags = {
    "kubernetes.io/cluster/jenkins-eks-cluster" = "shared"
    "kubernetes.io/role/elb" = 1
  }
}

module "eks" {

    source = "terraform-aws-modules/eks/aws"
    version = "~> 19.0"
    cluster_name = "jenkins-eks-cluster"
    cluster_version = "1.24"

    cluster_endpoint_public_access = true
    vpc_id = module.jenkins-vpc.vpc_id
    subnet_ids = module.jenkins-vpc.private_subnets

    tags = {

        environment = "development"
        application = "jenkins-app"
    }

    eks_managed_node_groups = {
        dev = {
            min_size = 1
            max_size = 3
            desired_size = 2
            instance_type = ["t2.small"]

        }
    }
}
