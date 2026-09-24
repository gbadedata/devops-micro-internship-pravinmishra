module "network" {
  source = "./modules/network"

  vpc_cidr    = var.vpc_cidr
  name_prefix = var.name_prefix
  azs         = var.azs
}
