variable "vpc_id" {
  description = "VPC ID"
  type        = string
}

variable "public_subnet_ids" {
  description = "Public subnet IDs"
  type        = list(string)
}

variable "private_subnet_ids" {
  description = "Private subnet IDs"
  type        = list(string)
}

variable "alb_security_group_id" {
  description = "ALB Security Group ID"
  type        = string
}

variable "ecs_security_group_id" {
  description = "ECS Security Group ID"
  type        = string
}

variable "environment" {
  description = "Environment name"
  type        = string
}

variable "aws_region" {
  description = "AWS region"
  type        = string
}

variable "web_server_image" {
  description = "Web server Docker image"
  type        = string
}

variable "msa1_image" {
  description = "MSA1 Docker image"
  type        = string
}

variable "msa2_image" {
  description = "MSA2 Docker image"
  type        = string
}

variable "msa3_image" {
  description = "MSA3 Docker image"
  type        = string
}
