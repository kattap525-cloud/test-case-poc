terraform {
  required_version = ">= 1.0"
  required_providers {
    aws = {
      source  = "hashicorp/aws"
      version = "~> 5.0"
    }
    random = {
      source  = "hashicorp/random"
      version = "~> 3.0"
    }
  }
}

provider "aws" {
  region = var.aws_region
}

# VPC and Networking
module "vpc" {
  source = "./modules/vpc"

  environment        = var.environment
  vpc_cidr           = var.vpc_cidr
  availability_zones = var.availability_zones
}

# Security Groups
module "security_groups" {
  source = "./modules/security_groups"

  vpc_id      = module.vpc.vpc_id
  environment = var.environment
}

# RDS Database
module "rds" {
  source = "./modules/rds"

  vpc_id             = module.vpc.vpc_id
  private_subnet_ids = module.vpc.private_subnet_ids
  security_group_id  = module.security_groups.rds_security_group_id
  environment        = var.environment
  db_username        = var.db_username
  db_password        = var.db_password
  db_instance_class  = var.db_instance_class
}

# DynamoDB
module "dynamodb" {
  source = "./modules/dynamodb"

  environment = var.environment
}

# ElastiCache Redis
module "elasticache" {
  source = "./modules/elasticache"

  vpc_id             = module.vpc.vpc_id
  private_subnet_ids = module.vpc.private_subnet_ids
  security_group_id  = module.security_groups.elasticache_security_group_id
  environment        = var.environment
  redis_node_type    = var.redis_node_type
}

# S3 Bucket for file storage
module "s3" {
  source = "./modules/s3"

  environment = var.environment
}

# ECS Cluster and Services
module "ecs" {
  source = "./modules/ecs"

  vpc_id                = module.vpc.vpc_id
  public_subnet_ids     = module.vpc.public_subnet_ids
  private_subnet_ids    = module.vpc.private_subnet_ids
  alb_security_group_id = module.security_groups.alb_security_group_id
  ecs_security_group_id = module.security_groups.ecs_security_group_id
  environment           = var.environment
  aws_region           = var.aws_region
  web_server_image      = var.web_server_image
  msa1_image            = var.msa1_image
  msa2_image            = var.msa2_image
  msa3_image            = var.msa3_image
}

# CloudWatch Logs and Monitoring
module "monitoring" {
  source = "./modules/monitoring"

  environment      = var.environment
  ecs_cluster_name = module.ecs.cluster_name
  rds_instance_id  = module.rds.instance_id
}
