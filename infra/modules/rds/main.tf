resource "aws_db_subnet_group" "this" {
  name       = "${var.name}-db-subnets"
  subnet_ids = var.private_subnet_ids

  tags = merge(var.tags, {
    Name = "${var.name}-db-subnets"
  })
}

resource "aws_db_parameter_group" "this" {
  name   = "${var.name}-db-params"
  family = var.engine == "postgres" ? "postgres16" : "${var.engine}${var.engine_version}"

  tags = merge(var.tags, {
    Name = "${var.name}-db-params"
  })
}

resource "aws_db_instance" "this" {
  identifier = "${var.name}-db"

  engine         = var.engine
  engine_version = var.engine_version
  instance_class = var.instance_class

  allocated_storage = var.allocated_storage
  storage_type      = var.storage_type

  db_name  = var.db_name
  username = var.db_user
  password = var.db_password
  port     = var.port

  multi_az            = var.multi_az
  publicly_accessible = var.publicly_accessible

  vpc_security_group_ids = [var.rds_sg_id]
  db_subnet_group_name   = aws_db_subnet_group.this.name
  parameter_group_name   = aws_db_parameter_group.this.name

  backup_retention_period = var.backup_retention_period

  deletion_protection = var.deletion_protection
  skip_final_snapshot = var.skip_final_snapshot

  # For short-lived demos faster changes & avoid surprise replacement issues.
  apply_immediately = true

  tags = merge(var.tags, {
    Name = "${var.name}-db"
  })
}
