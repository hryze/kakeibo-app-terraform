resource "aws_elasticache_subnet_group" "kakeibo_elasticache_subnet_group" {
  name       = "kakeibo-elasticache-subnet-group"
  subnet_ids = local.private_subnet_ids
}

resource "aws_elasticache_replication_group" "kakeibo_elasticache_replication_group" {
  replication_group_id          = "kakeibo-elasticache-replication-group"
  replication_group_description = "kakeibo elasticache replication group"
  engine                        = "redis"
  engine_version                = "5.0.6"
  number_cache_clusters         = 1
  node_type                     = "cache.t3.small"
  automatic_failover_enabled    = false
  port                          = var.elasticache_port
  maintenance_window            = "mon:10:40-mon:11:40"
  apply_immediately             = false
  security_group_ids            = [aws_eks_cluster.kakeibo_eks_cluster.vpc_config[0].cluster_security_group_id]
  parameter_group_name          = aws_elasticache_parameter_group.kakeibo_elasticache_parameter_group.name
  subnet_group_name             = aws_elasticache_subnet_group.kakeibo_elasticache_subnet_group.name
  tags                          = merge(local.default_tags, tomap({ "Name" = "kakeibo-elasticache-replication-group" }))
}

resource "aws_elasticache_parameter_group" "kakeibo_elasticache_parameter_group" {
  family = "redis5.0"
  name   = "kakeibo-elasticache-parameter-group"

  parameter {
    name  = "cluster-enabled"
    value = "no"
  }
}
