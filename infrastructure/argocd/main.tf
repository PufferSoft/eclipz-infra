terraform {
  required_version = ">= 1.0.1"

  required_providers {
    aws = {
      source  = "hashicorp/aws"
      version = ">= 3.66.0"
    }
    kubernetes = {
      source  = "hashicorp/kubernetes"
      version = ">= 2.6.1"
    }
    helm = {
      source  = "hashicorp/helm"
      version = ">= 2.4.1"
    }
  }

  #backend "local" {
  #  path = "local_tf_state/terraform-main.tfstate"
  #}
}

data "aws_region" "current" {}

data "aws_availability_zones" "available" {}

data "aws_eks_cluster" "cluster" {
  name = module.aws-eks-accelerator-for-terraform.eks_cluster_id
}

data "aws_eks_cluster_auth" "cluster" {
  name = module.aws-eks-accelerator-for-terraform.eks_cluster_id
}

provider "aws" {
  region = "ap-south-1"
  alias  = "default"
}

provider "kubernetes" {
  experiments {
    manifest_resource = true
  }
  host                   = data.aws_eks_cluster.cluster.endpoint
  cluster_ca_certificate = base64decode(data.aws_eks_cluster.cluster.certificate_authority.0.data)
  token                  = data.aws_eks_cluster_auth.cluster.token
}

provider "helm" {
  kubernetes {
    host                   = data.aws_eks_cluster.cluster.endpoint
    token                  = data.aws_eks_cluster_auth.cluster.token
    cluster_ca_certificate = base64decode(data.aws_eks_cluster.cluster.certificate_authority.0.data)
   exec {
     api_version="client.authentication.k8s.io/v1beta1"
     args= ["eks","get-token","--cluster-name",local.cluster_name]
     command="aws"
   }
  }
}

locals {
  tenant          = var.tenant      # AWS account name or unique id for tenant
  environment     = var.environment # Environment area eg., preprod or prod
  zone            = var.zone        # Environment with in one sub_tenant or business unit
  cluster_version = "1.21"

  vpc_cidr = "10.0.0.0/16"
  vpc_name = join("-", [local.tenant, local.environment, local.zone, "vpc"])
  #  azs          = slice(data.aws_availability_zones.available.names, 0, 2) #Elvis
  azs                                     = slice(data.aws_availability_zones.available.names, 0, 3)
  cluster_name                            = join("-", [local.tenant, local.environment, local.zone, "eks"])
  cluster_security_group_additional_rules = var.cluster_security_group_additional_rules

  terraform_version = "Terraform v1.0.1"

  #---------------------------------------------------------------
  # ARGOCD ADD-ON APPLICATION
  #---------------------------------------------------------------


  #---------------------------------------------------------------
  # ARGOCD WORKLOAD APPLICATION
  #---------------------------------------------------------------

}

// creation of elastic IP for Bastion Host

 resource "aws_eip" "bastionIP" {
  instance = module.ec2_instance.id
  vpc      = true
}


resource "aws_security_group" "allow_ssl" {
  name        = "allow_ssl"
  description = "Allow ssl inbound traffic"
  vpc_id      = module.aws_vpc.vpc_id

  ingress {
    description      = "SSL from VPC"
    from_port        = 22
    to_port          = 22
    protocol         = "tcp"
    cidr_blocks      = ["0.0.0.0/0"]
    //ipv6_cidr_blocks = [aws_vpc.main.ipv6_cidr_block]
  }

  egress {
    from_port        = 0
    to_port          = 0
    protocol         = "-1"
    cidr_blocks      = ["0.0.0.0/0"]
    ipv6_cidr_blocks = ["::/0"]
  }

  tags = {
    Name = "allow_ssl"
  }
}


// Pem Key needs to be generated before otherwise terraform will throw an error
 module "ec2_instance" {
  source  = "terraform-aws-modules/ec2-instance/aws"

  name = "bastion_host"

  ami                    = "ami-0b0dcb5067f052a63"
  instance_type          = "t2.micro"
  key_name               = var.key_name  // --> Please create your key and type the name in variable.tf here
  monitoring             = true
  vpc_security_group_ids = [aws_security_group.allow_ssl.id]
  subnet_id              = module.aws_vpc.public_subnets[0]

}

#---------------------------------------------------------------
# VPC
#---------------------------------------------------------------

module "aws_vpc" {
  source  = "terraform-aws-modules/vpc/aws"
  version = "v3.2.0"

  name = local.vpc_name
  cidr = local.vpc_cidr
  azs  = local.azs

  public_subnets  = [for k, v in local.azs : cidrsubnet(local.vpc_cidr, 8, k)]
  private_subnets = [for k, v in local.azs : cidrsubnet(local.vpc_cidr, 8, k + 10)]

  create_igw           = true
  enable_nat_gateway   = true
  single_nat_gateway   = true
  enable_dns_hostnames = true

  public_subnet_tags = {
    "kubernetes.io/cluster/${local.cluster_name}" = "shared"
    "kubernetes.io/role/elb"                      = "1"
  }

  private_subnet_tags = {
    "kubernetes.io/cluster/${local.cluster_name}" = "shared"
    "kubernetes.io/role/internal-elb"             = "1"
  }

}

#---------------------------------------------------------------
# Example to consume aws-eks-accelerator-for-terraform module
#---------------------------------------------------------------

module "aws-eks-accelerator-for-terraform" {
  source = "../.."

  tenant            = local.tenant
  environment       = local.environment
  zone              = local.zone
  terraform_version = local.terraform_version

  # EKS Cluster VPC and Subnet mandatory config
  vpc_id             = module.aws_vpc.vpc_id
  private_subnet_ids = module.aws_vpc.private_subnets

  # EKS CONTROL PLANE VARIABLES
  cluster_version = local.cluster_version

  # Managed Node Group
  managed_node_groups = {
    mg_4 = {
      node_group_name = "managed-ondemand"
      instance_types  = ["t3.medium"]
      subnet_ids      = module.aws_vpc.private_subnets

      desired_size = "5"  #Elvis
      max_size     = "5"
      min_size     = "2"
    }
  }

  cluster_security_group_additional_rules = local.cluster_security_group_additional_rules

  node_security_group_additional_rules = {
    node_db_ingress = {
      description = "DB ingress to Kubernetes API"
      protocol    = "tcp"
      from_port   = 5432
      to_port     = 5432
      type        = "ingress"
      cidr_blocks = [module.aws_vpc.vpc_cidr_block]
    }

    node_db_egress = {
      description = "DB egress to Kubernetes API"
      protocol    = "tcp"
      from_port   = 5432
      to_port     = 5432
      type        = "egress"
      cidr_blocks = [module.aws_vpc.vpc_cidr_block]
    }
  }
}

module "kubernetes-addons" {
  source = "../../modules/kubernetes-addons"

  eks_cluster_id = module.aws-eks-accelerator-for-terraform.eks_cluster_id

  #---------------------------------------------------------------
  # ARGO CD ADD-ON
  #---------------------------------------------------------------

  enable_argocd         = true
  argocd_manage_add_ons = true # Indicates that ArgoCD is responsible for managing/deploying Add-ons.
  argocd_applications = {
   addons = {
     path               = "chart"
     repo_url           = "https://github.com/aws-samples/eks-blueprints-add-ons.git"
     add_on_application = true # Indicates the root add-on application.
   },
   vault = {
     path               = "."
       repo_url           = "https://github.com/nouman2ahmed/vault-helm"
      // repo_url           = "https://github.com/hashicorp/vault-helm"
       add_on_application = false # Indicates the root add-on application.
   }
  }

  //grafana = {
  //  enable = true
  //}
  #---------------------------------------------------------------
  # ADD-ONS
  #---------------------------------------------------------------



//  enable_vault = true
  enable_aws_for_fluentbit             = false
  enable_grafana                       = true
  enable_promtail                      = true
  enable_tetrate_istio                 = true
  enable_amazon_eks_aws_ebs_csi_driver = true
  enable_aws_load_balancer_controller  = true
  enable_cert_manager                  = false
  enable_cluster_autoscaler            = false
  enable_ingress_nginx                 = true
  enable_karpenter                     = false #Elvis
  enable_keda                          = false
  enable_metrics_server                = false
  enable_prometheus                    = true
  enable_traefik                       = false
  enable_vpa                           = false
  enable_yunikorn                      = false
  enable_argo_rollouts                 = false
  enable_jenkins                       = false

  depends_on = [
    module.aws-eks-accelerator-for-terraform
  ]
}
