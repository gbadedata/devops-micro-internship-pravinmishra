# Non-secret values only. The DB password comes from TF_VAR_db_password;
# account_id and my_ip_cidr live in the git-ignored local.auto.tfvars.
region             = "eu-west-2"
name_prefix        = "oluwagbade-epicbook"
vpc_cidr           = "10.0.0.0/16"
public_subnet_cidr = "10.0.1.0/24"
db_subnet_a_cidr   = "10.0.2.0/24"
db_subnet_b_cidr   = "10.0.3.0/24"
instance_type      = "t3.micro"
public_key_path    = "~/.ssh/id_rsa.pub"
db_instance_class  = "db.t3.micro"
db_name            = "bookstore"
db_username        = "epicbook_admin"
