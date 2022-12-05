# create the eks cluster
module "eks-cluster-with-import-vpc" {
  #  source = "../../../infrastructure/eks-cluster-with-import-vpc/eks"
  #  source = "../../../infrastructure/eks-cluster-with-new-vpc"
  source = "../../../infrastructure/argocd"

  tenant      = var.tenant
  environment = var.environment
  zone        = var.zone
  region      = var.region

}

# create the ecr registrys
 module "ecr_registry" {
  source = "../../../infrastructure/ecr"

  tenant      = var.tenant
  environment = var.environment
  zone        = var.zone
  region      = var.region

  image_names = [
    "admingui-frontend-${var.tenant}-${var.environment}-${var.zone}-${var.region}",
    "admingui-backend-${var.tenant}-${var.environment}-${var.zone}-${var.region}",
    "admingui-controller-${var.tenant}-${var.environment}-${var.zone}-${var.region}"
  ]
}

# create the rds databases
module "rds_postgres" {
  source = "../../../infrastructure/database/rds-aurora-postgres"

  tenant      = var.tenant
  environment = var.environment
  zone        = var.zone
  region      = var.region

  vpc_id                  = module.eks-cluster-with-import-vpc.vpc_id
  allowed_cidr_blocks     = [module.eks-cluster-with-import-vpc.cidr_block]
  allowed_security_groups = [module.eks-cluster-with-import-vpc.eks_worker_security_group_id]
  subnets                 = module.eks-cluster-with-import-vpc.private_subnets

  # rds settings
  engine_version = "11.13"
  instance_class = "db.t3.medium"
  instances = {
    one = {}
  }
}
