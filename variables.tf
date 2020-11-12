variable "project" {
  type        = string
  default     = "kakeibo"
  description = "Project Name"
}

variable "environment" {
  type        = string
  default     = "prod"
  description = "Environment in which to deploy application"
}

variable "default_region" {
  type        = string
  default     = "ap-northeast-1"
  description = "Default region"
}

variable "acm_region" {
  type        = string
  default     = "us-east-1"
  description = "ACM region"
}

variable "availability_zones" {
  type = list(string)
  default = [
    "ap-northeast-1a",
    "ap-northeast-1c",
    "ap-northeast-1d",
  ]
  description = "Availability zones"
}

variable "vpc_cider_block" {
  type        = string
  default     = "10.0.0.0/16"
  description = "Cider block for vpc"
}

variable "public_subnet_cider_blocks" {
  type = list(string)
  default = [
    "10.0.1.0/24",
    "10.0.2.0/24",
    "10.0.3.0/24",
  ]
  description = "Cider blocks for public subnet"
}

variable "private_subnet_cider_blocks" {
  type = list(string)
  default = [
    "10.0.4.0/24",
    "10.0.5.0/24",
    "10.0.6.0/24",
  ]
  description = "Cider blocks for private subnet"
}

variable "root_domain" {
  type        = string
  default     = "shakepiper.com"
  description = "Domain name"
}

variable "website_domain" {
  type        = string
  default     = "www.shakepiper.com"
  description = "Subdomain for website"
}

variable "s3_bucketname" {
  type        = string
  default     = "kakeibo-front-web"
  description = "S3 bucket name"
}

variable "elasticache_port" {
  type        = number
  default     = 6379
  description = "Password for ElastiCache"
}

variable "rds_port" {
  type        = number
  default     = 3306
  description = "Port for RDS"
}

variable "rds_user" {
  type        = string
  description = "User for RDS"
}

variable "rds_password" {
  type        = string
  description = "Password for RDS"
}

variable "rds_secret" {
  type        = map(string)
  description = "Secret for RDS"
}

variable "user_db_dsn" {
  type        = map(string)
  description = "DSN for user service"
}

variable "account_db_dsn" {
  type        = map(string)
  description = "DSN for account service"
}

variable "todo_db_dsn" {
  type        = map(string)
  description = "DSN for todo service"
}

locals {
  default_tags     = merge(local.project_tag, local.environment_tag)
  eks_tag          = map(format("kubernetes.io/cluster/%s", local.cluster_name), "shared")
  elb_tag          = map("kubernetes.io/role/elb", 1)
  internal_elb_tag = map("kubernetes.io/role/internal-elb", 1)

  project_tag     = map("Project", var.project)
  environment_tag = map("Environment", var.environment)
}

locals {
  cluster_name    = format("%s-cluster", local.base_name)
  cluster_version = "1.18"

  base_name = format("%s-%s", var.project, var.environment)
}

locals {
  public_subnets = {
    public_subnet_1a = {
      cidr   = element(var.public_subnet_cider_blocks, 0)
      zone   = element(var.availability_zones, 0)
      launch = true
      name   = map("Name", format("kakeibo-public-subnet-%s", element(var.availability_zones, 0)))
    }
    public_subnet_1c = {
      cidr   = element(var.public_subnet_cider_blocks, 1)
      zone   = element(var.availability_zones, 1)
      launch = true
      name   = map("Name", format("kakeibo-public-subnet-%s", element(var.availability_zones, 1)))
    }
    public_subnet_1d = {
      cidr   = element(var.public_subnet_cider_blocks, 2)
      zone   = element(var.availability_zones, 2)
      launch = true
      name   = map("Name", format("kakeibo-public-subnet-%s", element(var.availability_zones, 2)))
    }
  }

  private_subnets = {
    private_subnet_1a = {
      cidr   = element(var.private_subnet_cider_blocks, 0)
      zone   = element(var.availability_zones, 0)
      launch = false
      name   = map("Name", format("kakeibo-private-subnet-%s", element(var.availability_zones, 0)))
    }
    private_subnet_1c = {
      cidr   = element(var.private_subnet_cider_blocks, 1)
      zone   = element(var.availability_zones, 1)
      launch = false
      name   = map("Name", format("kakeibo-private-subnet-%s", element(var.availability_zones, 1)))
    }
    private_subnet_1d = {
      cidr   = element(var.private_subnet_cider_blocks, 2)
      zone   = element(var.availability_zones, 2)
      launch = false
      name   = map("Name", format("kakeibo-private-subnet-%s", element(var.availability_zones, 2)))
    }
  }

  public_subnet_ids  = [for public_subnet in aws_subnet.kakeibo_public_subnets : public_subnet.id]
  private_subnet_ids = [for private_subnet in aws_subnet.kakeibo_private_subnets : private_subnet.id]
}

locals {
  s3_origin_id = format("s3-origin-%s", var.website_domain)
}
