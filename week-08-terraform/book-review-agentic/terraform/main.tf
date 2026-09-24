module "network" {
  source = "./modules/network"

  vpc_cidr    = var.vpc_cidr
  name_prefix = var.name_prefix
  azs         = var.azs
}

module "security" {
  source = "./modules/security"

  vpc_id      = module.network.vpc_id
  name_prefix = var.name_prefix
  my_ip_cidr  = var.my_ip_cidr
  db_password = var.db_password
  jwt_secret  = var.jwt_secret
}

module "load_balancer" {
  source = "./modules/load-balancer"

  vpc_id             = module.network.vpc_id
  name_prefix        = var.name_prefix
  web_subnet_ids     = module.network.web_subnet_ids
  app_subnet_ids     = module.network.app_subnet_ids
  alb_public_sg_id   = module.security.alb_public_sg_id
  alb_internal_sg_id = module.security.alb_internal_sg_id
}
