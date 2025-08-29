variable "aws_region" {
  description = "AWS region to deploy resources"
  type        = string
  default     = "us-east-1"
}

variable "environment" {
  description = "Environment name (e.g., prod, staging, dev)"
  type        = string
  default     = "prod"
}

variable "vpc_cidr" {
  description = "CIDR block for VPC"
  type        = string
  default     = "10.0.0.0/16"
}

variable "availability_zones" {
  description = "Availability zones"
  type        = list(string)
  default     = ["us-east-1a", "us-east-1b", "us-east-1c"]
}

variable "db_username" {
  description = "Database username"
  type        = string
  default     = "admin"
}

variable "db_password" {
  description = "Database password"
  type        = string
  sensitive   = true
}

variable "instance_type" {
  description = "EC2 instance type"
  type        = string
  default     = "t3.micro"
}

variable "db_instance_class" {
  description = "RDS instance class"
  type        = string
  default     = "db.t3.micro"
}

variable "redis_node_type" {
  description = "ElastiCache Redis node type"
  type        = string
  default     = "cache.t3.micro"
}

variable "web_server_image" {
  description = "Web server Docker image"
  type        = string
  default     = "ecommerce/web-server:latest"
}

variable "msa1_image" {
  description = "MSA1 Docker image"
  type        = string
  default     = "ecommerce/msa1:latest"
}

variable "msa2_image" {
  description = "MSA2 Docker image"
  type        = string
  default     = "ecommerce/msa2:latest"
}

variable "msa3_image" {
  description = "MSA3 Docker image"
  type        = string
  default     = "ecommerce/msa3:latest"
}
