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

module "database" {
  source = "./modules/database"

  name_prefix   = var.name_prefix
  db_subnet_ids = module.network.db_subnet_ids
  db_sg_id      = module.security.db_sg_id
  db_username   = var.db_username
  db_password   = var.db_password
}

module "compute" {
  source = "./modules/compute"

  name_prefix = var.name_prefix
  aws_region  = var.aws_region

  web_subnet_ids = module.network.web_subnet_ids
  app_subnet_ids = module.network.app_subnet_ids
  web_sg_id      = module.security.web_sg_id
  app_sg_id      = module.security.app_sg_id

  web_instance_profile_name = module.security.web_instance_profile_name
  app_instance_profile_name = module.security.app_instance_profile_name

  web_tg_arn = module.load_balancer.web_tg_arn
  app_tg_arn = module.load_balancer.app_tg_arn

  internal_alb_dns_name = module.load_balancer.internal_alb_dns_name
  public_alb_dns_name   = module.load_balancer.public_alb_dns_name

  db_primary_address = module.database.primary_address
  db_name            = module.database.db_name
  db_username        = var.db_username

  db_password_parameter_name = module.security.db_password_parameter_name
  jwt_secret_parameter_name  = module.security.jwt_secret_parameter_name

  public_key_path = var.public_key_path
  repo_url        = var.repo_url
  repo_ref        = var.repo_ref
}
