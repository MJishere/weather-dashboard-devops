module "vpc" {
  source       = "./vpc"
  project_name = var.project_name
}

module "ecr" {
  source       = "./ecr"
  project_name = var.project_name
}

module "eks" {
  source             = "./eks"
  project_name      = var.project_name
  vpc_id             = module.vpc.vpc_id
  public_subnet_ids  = module.vpc.public_subnet_ids
  private_subnet_ids = module.vpc.private_subnet_ids
}