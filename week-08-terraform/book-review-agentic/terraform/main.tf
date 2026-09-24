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
