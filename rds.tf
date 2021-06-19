resource "aws_db_subnet_group" "kakeibo_rds_subnet_group" {
  name       = "kakeibo-rds-subnet-group"
  subnet_ids = local.private_subnet_ids
  tags       = merge(local.default_tags, tomap({ "Name" = "kakeibo-rds-subnet-group" }))
}

resource "aws_db_instance" "kakeibo_rds_instance" {
  identifier                 = "kakeibo-rds-instance"
  engine                     = "mysql"
  engine_version             = "8.0.20"
  instance_class             = "db.t3.small"
  storage_type               = "gp2"
  allocated_storage          = 20
  max_allocated_storage      = 100
  username                   = var.rds_user
  password                   = var.rds_password
  publicly_accessible        = false
  port                       = var.rds_port
  availability_zone          = element(var.availability_zones, 0)
  backup_window              = "09:10-09:40"
  backup_retention_period    = 30
  maintenance_window         = "mon:10:10-mon:10:40"
  auto_minor_version_upgrade = false
  delete_automated_backups   = true
  skip_final_snapshot        = true
  apply_immediately          = false
  vpc_security_group_ids     = [aws_eks_cluster.kakeibo_eks_cluster.vpc_config[0].cluster_security_group_id]
  db_subnet_group_name       = aws_db_subnet_group.kakeibo_rds_subnet_group.name
  option_group_name          = aws_db_option_group.kakeibo_rds_option_group.name
  parameter_group_name       = aws_db_parameter_group.kakeibo_rds_parameter_group.name
  tags                       = merge(local.default_tags, tomap({ "Name" = "kakeibo-rds-instance" }))

  enabled_cloudwatch_logs_exports = [
    "error",
    "general",
    "slowquery"
  ]

  lifecycle {
    ignore_changes = [
      username,
      password,
    ]
  }
}

resource "aws_db_option_group" "kakeibo_rds_option_group" {
  name                 = "kakeibo-rds-option-group"
  engine_name          = "mysql"
  major_engine_version = "8.0"
  tags                 = merge(local.default_tags, tomap({ "Name" = "kakeibo-rds-option-group" }))
}

resource "aws_db_parameter_group" "kakeibo_rds_parameter_group" {
  name   = "kakeibo-rds-parameter-group"
  family = "mysql8.0"
  tags   = merge(local.default_tags, tomap({ "Name" = "kakeibo-rds-parameter-group" }))

  parameter {
    name  = "slow_query_log"
    value = 1
  }

  parameter {
    name  = "general_log"
    value = 1
  }

  parameter {
    name  = "long_query_time"
    value = 0.1
  }

  parameter {
    name  = "time_zone"
    value = "Asia/Tokyo"
  }

  parameter {
    name  = "character_set_client"
    value = "utf8mb4"
  }

  parameter {
    name  = "character_set_connection"
    value = "utf8mb4"
  }

  parameter {
    name  = "character_set_database"
    value = "utf8mb4"
  }

  parameter {
    name  = "character_set_results"
    value = "utf8mb4"
  }

  parameter {
    name  = "character_set_server"
    value = "utf8mb4"
  }

  parameter {
    name  = "collation_connection"
    value = "utf8mb4_general_ci"
  }

  parameter {
    name  = "collation_server"
    value = "utf8mb4_general_ci"
  }
}
