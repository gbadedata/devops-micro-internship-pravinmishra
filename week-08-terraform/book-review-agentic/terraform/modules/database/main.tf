# --- DB subnet group ---

resource "aws_db_subnet_group" "main" {
  name        = "${var.name_prefix}-db-subnet-group"
  description = "DB subnet group for the Book Review App"
  subnet_ids  = var.db_subnet_ids

  tags = {
    Name = "${var.name_prefix}-db-subnet-group"
    Tier = "db"
  }
}

# --- Parameter group ---
# require_secure_transport = 1 makes the server reject non-TLS connections.
# It takes effect without a reboot, so it is applied immediately.

resource "aws_db_parameter_group" "mysql" {
  name        = "${var.name_prefix}-mysql84"
  family      = "mysql8.4"
  description = "MySQL 8.4 parameter group for the Book Review App"

  parameter {
    name         = "require_secure_transport"
    value        = "1"
    apply_method = "immediate"
  }

  tags = {
    Name = "${var.name_prefix}-mysql84"
    Tier = "db"
  }
}

# --- Primary instance (Multi-AZ) ---
# password_wo is a write-only argument: the password is never persisted to
# state. To rotate it, bump password_wo_version (e.g. 1 -> 2) alongside the
# new TF_VAR_db_password value -- changing the variable alone will not trigger
# an update. Also bump value_wo_version on the db_password SSM parameter in the
# security module so the app reads the same new password.

resource "aws_db_instance" "primary" {
  identifier               = "${var.name_prefix}-db-primary"
  engine                   = "mysql"
  engine_version           = "8.4"
  engine_lifecycle_support = "open-source-rds-extended-support-disabled"
  instance_class           = "db.t3.micro"
  allocated_storage        = 20
  storage_type             = "gp3"
  storage_encrypted        = true
  multi_az                 = true
  publicly_accessible      = false
  db_subnet_group_name     = aws_db_subnet_group.main.name
  parameter_group_name     = aws_db_parameter_group.mysql.name
  vpc_security_group_ids   = [var.db_sg_id]
  db_name                  = "book_review_db"
  username                 = var.db_username
  password_wo              = var.db_password
  password_wo_version      = 1
  backup_retention_period  = 1
  skip_final_snapshot      = true
  deletion_protection      = false
  apply_immediately        = true

  tags = {
    Name = "${var.name_prefix}-db-primary"
    Tier = "db"
  }
}

# --- Read replica ---
# A same-region MySQL replica inherits the primary's engine version,
# parameter group (TLS enforcement), subnet group and KMS key; RDS does not
# accept a parameter group or lifecycle setting for it, and storage defaults
# to gp3.

resource "aws_db_instance" "replica" {
  identifier              = "${var.name_prefix}-db-replica"
  replicate_source_db     = aws_db_instance.primary.identifier
  instance_class          = "db.t3.micro"
  storage_encrypted       = true
  publicly_accessible     = false
  vpc_security_group_ids  = [var.db_sg_id]
  backup_retention_period = 0
  skip_final_snapshot     = true
  deletion_protection     = false
  apply_immediately       = true

  tags = {
    Name = "${var.name_prefix}-db-replica"
    Tier = "db"
  }
}
